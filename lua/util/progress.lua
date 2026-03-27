local M = {}

local frames = { "|", "/", "-", "\\" }
local lazy_busy = false
local lsp_busy = false
local setup_done = false
local tick = nil

local function spinner()
  local i = math.floor(vim.uv.hrtime() / 1e8) % #frames + 1
  return frames[i]
end

local function parse_percent(text)
  if type(text) ~= "string" or text == "" then
    return nil
  end
  local p = text:match("(%d?%d?%d)%%")
  if not p then
    return nil
  end
  p = tonumber(p)
  if not p then
    return nil
  end
  if p < 0 then
    p = 0
  elseif p > 100 then
    p = 100
  end
  return p
end

local function compact(text, max_len)
  if #text <= max_len then
    return text
  end
  return text:sub(1, max_len - 3) .. "..."
end

function M.setup()
  if setup_done then
    return
  end
  setup_done = true

  local group = vim.api.nvim_create_augroup("StatusProgressBar", { clear = true })
  local redraw = function()
    pcall(vim.cmd, "redrawstatus")
  end

  local function apply_busy_state()
    local any_busy = lazy_busy or lsp_busy
    if any_busy and tick == nil then
      tick = vim.uv.new_timer()
      if tick then
        tick:start(0, 120, vim.schedule_wrap(redraw))
      end
    elseif not any_busy and tick then
      tick:stop()
      tick:close()
      tick = nil
    end
    redraw()
  end

  vim.api.nvim_create_autocmd("LspProgress", {
    group = group,
    callback = function()
      local st = vim.trim(vim.lsp.status() or "")
      lsp_busy = st ~= ""
      apply_busy_state()
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = {
      "LazySyncPre",
      "LazyInstallPre",
      "LazyUpdatePre",
      "LazyCheckPre",
      "LazyCleanPre",
    },
    callback = function()
      lazy_busy = true
      apply_busy_state()
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = { "LazyDone", "LazySync", "LazyInstall", "LazyUpdate", "LazyCheck", "LazyClean" },
    callback = function()
      lazy_busy = false
      apply_busy_state()
    end,
  })
end

function M.component()
  local lsp_status = vim.trim(vim.lsp.status() or "")
  local busy = lazy_busy or lsp_status ~= ""
  if not busy then
    return ""
  end

  local width = math.max(14, math.min(36, math.floor(vim.o.columns * 0.22)))
  local pct = parse_percent(lsp_status)
  local fill = pct and math.floor((pct / 100) * width) or (math.floor(vim.uv.hrtime() / 2e8) % width)
  if fill < 0 then
    fill = 0
  elseif fill > width then
    fill = width
  end

  local bar = string.rep(".", width - fill) .. string.rep("=", fill)
  local label
  if lsp_status ~= "" then
    label = compact(lsp_status, 34)
  else
    label = "Lazy loading"
  end
  return string.format("%s [%s] %s", spinner(), bar, label)
end

return M
