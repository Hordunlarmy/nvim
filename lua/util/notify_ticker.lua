local M = {}

local queue = {}
local current = nil
local offset = 0
local timer = nil
local history = {}
local MAX_HISTORY = 400

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
  local min_timeout = 7000
  if type(opts) == "table" and type(opts.timeout) == "number" and opts.timeout > 0 then
    return clamp(math.floor(opts.timeout), min_timeout, 30000)
  end

  local base = clamp(1400 + (#text * 95), min_timeout, 22000)
  if level == vim.log.levels.ERROR then
    base = math.min(base + 2200, 26000)
  elseif level == vim.log.levels.WARN then
    base = math.min(base + 1200, 24000)
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

local function next_entry()
  if #queue == 0 then
    current = nil
    offset = 0
    return
  end

  current = table.remove(queue, 1)
  current.started_at = now_ms()
  offset = 0
end

local function ensure_timer()
  if timer then
    return
  end
  timer = vim.uv.new_timer()
  if not timer then
    return
  end

  timer:start(
    0,
    120,
    vim.schedule_wrap(function()
      if not current then
        stop_timer()
        redraw()
        return
      end

      offset = offset + 1
      local started_at = current.started_at or now_ms()
      if now_ms() - started_at >= (current.timeout or 2500) then
        next_entry()
        if not current then
          stop_timer()
          redraw()
          return
        end
      end

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

  table.insert(queue, {
    text = text,
    level = sev,
    timeout = resolve_timeout(text, sev, opts),
  })

  if not current then
    next_entry()
  end
  ensure_timer()
  redraw()
end

function M.clear()
  queue = {}
  current = nil
  offset = 0
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

function M.show_history(opts)
  opts = opts or {}
  local entries = M.get_history()

  local lines = {}
  if #entries == 0 then
    lines = { "No messages in history." }
  elseif opts.last then
    local item = entries[#entries]
    lines = {
      string.format("[%s] [%s]", item.ts or "--:--:--", level_tag(item.level)),
      "",
      item.text or "",
    }
  else
    for _, item in ipairs(entries) do
      lines[#lines + 1] = string.format("[%s] [%s] %s", item.ts or "--:--:--", level_tag(item.level), item.text or "")
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

  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true
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

  return true
end

local function marquee(text, width, always_roll)
  local gap = "   "
  local loop = text .. gap
  if not always_roll and #text <= width then
    return text
  end
  if always_roll and #text < width then
    loop = text .. string.rep(" ", math.max(4, width - #text)) .. gap
  end
  local n = #loop
  local start = (offset % n) + 1
  local piece = loop:sub(start, start + width - 1)
  if #piece < width then
    piece = piece .. loop:sub(1, width - #piece)
  end
  return piece
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
