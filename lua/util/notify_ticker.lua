local M = {}

local current = nil
local timer = nil
local history = {}
local MAX_HISTORY = 400
local HISTORY_VIEW_LIMIT = 120
local HISTORY_LINE_LIMIT = 320

local function now_ms()
  return math.floor(vim.uv.hrtime() / 1e6)
end

local function redraw()
  pcall(vim.cmd, "redrawtabline")
  pcall(vim.cmd, "redrawstatus")
end

local function normalize_message(msg)
  if msg == nil then
    return nil
  end
  local function sanitize(s)
    s = s:gsub("[%z\1-\8\11\12\14-\31\127]", " ")
    s = vim.trim(s:gsub("%s+", " "))
    return s ~= "" and s or nil
  end
  if type(msg) == "string" then
    return sanitize(msg)
  end
  local ok, inspected = pcall(vim.inspect, msg)
  if not ok then
    return nil
  end
  return sanitize(inspected)
end

local function clamp(value, min_v, max_v)
  return math.max(min_v, math.min(max_v, value))
end

local function resolve_timeout(text, level, opts)
  local min_timeout = 1400
  if type(opts) == "table" and type(opts.timeout) == "number" and opts.timeout > 0 then
    return clamp(math.floor(opts.timeout), min_timeout, 7000)
  end

  local base = clamp(1200 + (#text * 28), min_timeout, 5200)
  if level == vim.log.levels.ERROR then
    base = math.min(base + 900, 6500)
  elseif level == vim.log.levels.WARN then
    base = math.min(base + 500, 6000)
  end
  return base
end

local function stop_timer()
  if not timer then
    return
  end
  timer:stop()
  timer:close()
  timer = nil
end

local function schedule_clear(timeout)
  stop_timer()
  timer = vim.uv.new_timer()
  if not timer then
    return
  end
  timer:start(
    timeout or 2500,
    0,
    vim.schedule_wrap(function()
      current = nil
      stop_timer()
      redraw()
    end)
  )
end

function M.push(msg, level, opts)
  local text = normalize_message(msg)
  if not text then
    return
  end

  local sev = level or vim.log.levels.INFO
  table.insert(history, {
    text = text,
    level = sev,
    ts = os.date("%H:%M:%S"),
  })
  if #history > MAX_HISTORY then
    table.remove(history, 1)
  end

  current = {
    text = text,
    level = sev,
    timeout = resolve_timeout(text, sev, opts),
  }
  schedule_clear(current.timeout)
  redraw()
end

function M.clear()
  current = nil
  stop_timer()
  redraw()
end

function M.has_current()
  return current ~= nil
end

function M.get_history()
  local out = {}
  for i = 1, #history do
    out[i] = history[i]
  end
  return out
end

local function level_tag(level)
  if level == vim.log.levels.ERROR then
    return "ERROR"
  elseif level == vim.log.levels.WARN then
    return "WARN"
  elseif level == vim.log.levels.DEBUG then
    return "DEBUG"
  end
  return "INFO"
end

local function trim_line(text, max_len)
  local s = tostring(text or "")
  if #s <= max_len then
    return s
  end
  return s:sub(1, max_len - 3) .. "..."
end

function M.show_history(opts)
  opts = opts or {}
  local entries = M.get_history()
  if not opts.last and #entries > HISTORY_VIEW_LIMIT then
    entries = { unpack(entries, #entries - HISTORY_VIEW_LIMIT + 1, #entries) }
  end

  local lines = {}
  if #entries == 0 then
    lines = { "No messages in history." }
  elseif opts.last then
    local item = entries[#entries]
    lines = {
      string.format("[%s] [%s]", item.ts or "--:--:--", level_tag(item.level)),
      "",
      trim_line(item.text or "", HISTORY_LINE_LIMIT),
    }
  else
    for _, item in ipairs(entries) do
      lines[#lines + 1] = string.format(
        "[%s] [%s] %s",
        item.ts or "--:--:--",
        level_tag(item.level),
        trim_line(item.text or "", HISTORY_LINE_LIMIT)
      )
    end
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  local cur_win = vim.api.nvim_get_current_win()
  local win_w = vim.api.nvim_win_get_width(cur_win)
  local win_h = vim.api.nvim_win_get_height(cur_win)
  local width = math.min(math.max(70, math.floor(win_w * 0.90)), 140)
  local height = math.min(math.max(10, math.floor(win_h * 0.78)), math.max(3, #lines + 2))
  local row = math.max(0, math.floor((win_h - height) / 2))
  local col = math.max(0, math.floor((win_w - width) / 2))

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "win",
    win = cur_win,
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
  })

  vim.wo[win].wrap = false
  vim.wo[win].linebreak = false
  vim.wo[win].cursorline = true
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false

  local function close_win()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end
  vim.keymap.set("n", "q", close_win, { buffer = buf, silent = true, nowait = true })
  vim.keymap.set("n", "<Esc>", close_win, { buffer = buf, silent = true, nowait = true })
  -- Avoid clipboard-provider/yanky stalls for large selections in this view.
  vim.keymap.set("n", "yy", '"0yy', { buffer = buf, silent = true, nowait = true, remap = false })
  vim.keymap.set("n", "Y", '"0Y', { buffer = buf, silent = true, nowait = true, remap = false })
  vim.keymap.set("x", "y", '"0y', { buffer = buf, silent = true, nowait = true, remap = false })

  return true
end

local function marquee(text, width, always_roll)
  if not always_roll and vim.fn.strdisplaywidth(text) <= width then
    return text
  end
  if vim.fn.strdisplaywidth(text) <= width then
    return text
  end
  return vim.fn.strcharpart(text, 0, width - 1) .. "…"
end

function M.component(max_width)
  if not current then
    return {}
  end

  local width = max_width or 40
  local icon = ""
  local fg = "#7aa2f7"

  if current.level == vim.log.levels.ERROR then
    icon = ""
    fg = "#f7768e"
  elseif current.level == vim.log.levels.WARN then
    icon = ""
    fg = "#e0af68"
  elseif current.level == vim.log.levels.INFO then
    icon = ""
    fg = "#7dcfff"
  elseif current.level == vim.log.levels.DEBUG then
    icon = ""
    fg = "#9ece6a"
  end

  local text = marquee(current.text, width, false)
  return {
    { text = " " .. icon .. " " .. text .. " ", fg = fg, bg = "NONE" },
  }
end

function M.statusline(max_width)
  if not current then
    return ""
  end

  local width = max_width or 44
  local icon = ""
  if current.level == vim.log.levels.ERROR then
    icon = ""
  elseif current.level == vim.log.levels.WARN then
    icon = ""
  elseif current.level == vim.log.levels.DEBUG then
    icon = ""
  end

  return icon .. " " .. marquee(current.text, width, false)
end

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = vim.api.nvim_create_augroup("NotifyTicker", { clear = true }),
  callback = function()
    stop_timer()
  end,
})

return M
