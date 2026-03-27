local M = {}

local queue = {}
local current = nil
local offset = 0
local timer = nil

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
  if type(opts) == "table" and type(opts.timeout) == "number" and opts.timeout > 0 then
    return clamp(math.floor(opts.timeout), 800, 30000)
  end

  local base = clamp(1400 + (#text * 95), 4200, 22000)
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

  return icon .. " " .. marquee(current.text, width, true)
end

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = vim.api.nvim_create_augroup("NotifyTicker", { clear = true }),
  callback = function()
    stop_timer()
  end,
})

return M
