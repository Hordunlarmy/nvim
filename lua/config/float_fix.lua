-- Force floats to stay scoped to an actual window (not full editor grid).
-- This catches all code paths by patching nvim_open_win/nvim_win_set_config.

-- This global monkey-patch is expensive and can cause UI churn/stalls.
-- Keep it opt-in for debugging only.
if vim.g.enable_float_fix ~= true then
  return {}
end

local group = vim.api.nvim_create_augroup("FloatFix", { clear = true })
local state = { last_normal_win = nil }

local function is_valid_win(win)
  return type(win) == "number" and win > 0 and vim.api.nvim_win_is_valid(win)
end

local function is_float(win)
  if not is_valid_win(win) then
    return false
  end
  local ok, cfg = pcall(vim.api.nvim_win_get_config, win)
  return ok and cfg and cfg.relative and cfg.relative ~= ""
end

local function is_normal_win(win)
  return is_valid_win(win) and (not is_float(win))
end

local function clamp(value, min_v, max_v)
  return math.max(min_v, math.min(max_v, value))
end

local function as_number(value, default)
  if type(value) == "table" then
    value = value[false] or value[1]
  end
  local n = tonumber(value)
  if n == nil then
    return default
  end
  return n
end

local function to_int(value, default)
  return math.floor(as_number(value, default or 0))
end

local function in_telescope_stack()
  for level = 3, 18 do
    local info = debug.getinfo(level, "S")
    if not info then
      break
    end
    local src = info.source or ""
    if src:find("telescope", 1, true) then
      return true
    end
  end
  return false
end

local function buf_filetype(bufnr)
  if type(bufnr) ~= "number" or bufnr <= 0 or not vim.api.nvim_buf_is_valid(bufnr) then
    return ""
  end
  return vim.bo[bufnr].filetype or ""
end

local function should_passthrough(cfg, existing_win, opening_buf)
  if in_telescope_stack() then
    return true
  end

  local ft = ""
  if type(opening_buf) == "number" and opening_buf > 0 then
    ft = buf_filetype(opening_buf)
  end
  if ft == "" and is_valid_win(existing_win) then
    ft = buf_filetype(vim.api.nvim_win_get_buf(existing_win))
  end

  if ft:match("^Telescope") then
    return true
  end

  return false
end

local function apply_float_style(win)
  if not is_float(win) then
    return
  end
  pcall(function()
    vim.wo[win].winblend = 0
    vim.wo[win].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,NormalNC:NormalFloat"
    vim.wo[win].sidescrolloff = 2
  end)
end

local function pick_anchor_from_tab()
  local wins = vim.api.nvim_tabpage_list_wins(0)
  local best_win = nil
  local best_area = -1

  for _, win in ipairs(wins) do
    if is_normal_win(win) then
      local buf = vim.api.nvim_win_get_buf(win)
      local bt = vim.bo[buf].buftype
      if bt == "" then
        local area = vim.api.nvim_win_get_width(win) * vim.api.nvim_win_get_height(win)
        if area > best_area then
          best_area = area
          best_win = win
        end
      elseif not best_win then
        best_win = win
      end
    end
  end

  return best_win
end

local function resolve_anchor(cfg)
  local target = cfg and cfg.win
  if target == 0 then
    target = nil
  end
  if is_normal_win(target) then
    return target
  end

  local cur = vim.api.nvim_get_current_win()
  if is_normal_win(cur) then
    return cur
  end

  if is_normal_win(state.last_normal_win) then
    return state.last_normal_win
  end

  return pick_anchor_from_tab()
end

local function coerce_float_config(cfg, existing_win)
  if type(cfg) ~= "table" then
    return cfg
  end

  local existing = nil
  if is_valid_win(existing_win) and is_float(existing_win) then
    local ok, prev = pcall(vim.api.nvim_win_get_config, existing_win)
    if ok and type(prev) == "table" then
      existing = prev
    end
  end

  local relative = cfg.relative or (existing and existing.relative)
  if type(relative) ~= "string" or relative == "" or cfg.external then
    return cfg
  end

  -- Keep child-floats anchored to their parent float (titles/prompt overlays).
  if relative == "win" and is_float(cfg.win) then
    return cfg
  end

  local anchor = resolve_anchor(cfg)
  if not is_normal_win(anchor) then
    return cfg
  end

  local anchor_w = vim.api.nvim_win_get_width(anchor)
  local anchor_h = vim.api.nvim_win_get_height(anchor)

  local width = clamp(to_int(cfg.width, existing and existing.width or anchor_w), 1, math.max(1, anchor_w))
  local height = clamp(to_int(cfg.height, existing and existing.height or anchor_h), 1, math.max(1, anchor_h))
  cfg.width = width
  cfg.height = height

  if relative == "editor" then
    local pos = vim.api.nvim_win_get_position(anchor)
    local anchor_row = pos[1]
    local anchor_col = pos[2]
    local max_row = math.max(0, anchor_h - height)
    local max_col = math.max(0, anchor_w - width)
    local abs_row = as_number(cfg.row, existing and existing.row or anchor_row)
    local abs_col = as_number(cfg.col, existing and existing.col or anchor_col)

    cfg.relative = "win"
    cfg.win = anchor
    cfg.row = clamp(math.floor(abs_row - anchor_row), 0, max_row)
    cfg.col = clamp(math.floor(abs_col - anchor_col), 0, max_col)
    return cfg
  end

  if relative == "win" then
    local target = cfg.win or (existing and existing.win)
    if target == 0 or not is_normal_win(target) then
      target = anchor
      cfg.win = target
    end

    local target_w = vim.api.nvim_win_get_width(target)
    local target_h = vim.api.nvim_win_get_height(target)
    cfg.width = clamp(cfg.width, 1, math.max(1, target_w))
    cfg.height = clamp(cfg.height, 1, math.max(1, target_h))

    local max_row = math.max(0, target_h - cfg.height)
    local max_col = math.max(0, target_w - cfg.width)
    cfg.row = clamp(to_int(cfg.row, existing and existing.row or 0), 0, max_row)
    cfg.col = clamp(to_int(cfg.col, existing and existing.col or 0), 0, max_col)
    return cfg
  end

  -- cursor/mouse/tabline/laststatus: at least enforce in-window size bounds.
  return cfg
end

vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "TabEnter" }, {
  group = group,
  callback = function()
    local win = vim.api.nvim_get_current_win()
    if is_normal_win(win) then
      state.last_normal_win = win
    end
  end,
})

vim.api.nvim_create_autocmd("WinNew", {
  group = group,
  callback = function()
    local win = vim.api.nvim_get_current_win()
    if is_float(win) then
      apply_float_style(win)
    elseif is_normal_win(win) then
      state.last_normal_win = win
    end
  end,
})

if not vim.g._float_fix_global_api_patched then
  vim.g._float_fix_global_api_patched = true

  local raw_open_win = vim.api.nvim_open_win
  vim.api.nvim_open_win = function(buffer, enter, config)
    local raw_cfg = vim.deepcopy(config or {})
    local patched = should_passthrough(raw_cfg, nil, buffer) and raw_cfg or coerce_float_config(raw_cfg, nil)
    local win = raw_open_win(buffer, enter, patched)
    apply_float_style(win)
    return win
  end

  local raw_win_set_config = vim.api.nvim_win_set_config
  vim.api.nvim_win_set_config = function(win, config)
    local raw_cfg = vim.deepcopy(config or {})
    local patched = should_passthrough(raw_cfg, win, nil) and raw_cfg or coerce_float_config(raw_cfg, win)
    return raw_win_set_config(win, patched)
  end
end

return {}
