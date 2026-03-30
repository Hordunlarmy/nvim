local M = {}

local function is_valid_win(win)
  return type(win) == "number" and win > 0 and vim.api.nvim_win_is_valid(win)
end

local function is_normal_win(win)
  if not is_valid_win(win) then
    return false
  end
  local cfg = vim.api.nvim_win_get_config(win)
  return not (cfg and cfg.relative and cfg.relative ~= "")
end

local function find_anchor(anchor_win)
  if is_normal_win(anchor_win) then
    return anchor_win
  end
  local cur = vim.api.nvim_get_current_win()
  if is_normal_win(cur) then
    return cur
  end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if is_normal_win(win) then
      return win
    end
  end
  return nil
end

function M.retarget_to_window(anchor_win)
  local anchor = find_anchor(anchor_win)
  if not anchor then
    return false
  end

  local floats = {}
  local min_row, min_col, max_row, max_col
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.bo[buf].filetype
    if ft == "TelescopePrompt" or ft == "TelescopeResults" or ft == "TelescopePreview" then
      local cfg = vim.api.nvim_win_get_config(win)
      if cfg and cfg.relative ~= "" then
        local row = tonumber(cfg.row) or 0
        local col = tonumber(cfg.col) or 0
        local width = tonumber(cfg.width) or 1
        local height = tonumber(cfg.height) or 1
        min_row = min_row and math.min(min_row, row) or row
        min_col = min_col and math.min(min_col, col) or col
        max_row = max_row and math.max(max_row, row + height + 2) or (row + height + 2)
        max_col = max_col and math.max(max_col, col + width + 2) or (col + width + 2)
        floats[#floats + 1] = { win = win, cfg = cfg, row = row, col = col }
      end
    end
  end

  if #floats == 0 or not min_row or not min_col or not max_row or not max_col then
    return false
  end

  local anchor_w = vim.api.nvim_win_get_width(anchor)
  local anchor_h = vim.api.nvim_win_get_height(anchor)
  local box_w = math.max(1, math.floor(max_col - min_col))
  local box_h = math.max(1, math.floor(max_row - min_row))
  local target_row = math.max(0, math.floor((anchor_h - box_h) / 2))
  local target_col = math.max(0, math.floor((anchor_w - box_w) / 2))
  local delta_row = target_row - min_row
  local delta_col = target_col - min_col

  for _, item in ipairs(floats) do
    local cfg = item.cfg
    cfg.relative = "win"
    cfg.win = anchor
    cfg.width = math.max(1, math.min(tonumber(cfg.width) or 1, math.max(1, anchor_w - 2)))
    cfg.height = math.max(1, math.min(tonumber(cfg.height) or 1, math.max(1, anchor_h - 2)))
    cfg.row = math.max(0, item.row + delta_row)
    cfg.col = math.max(0, item.col + delta_col)
    pcall(vim.api.nvim_win_set_config, item.win, cfg)
  end

  return true
end

function M.defer_retarget(anchor_win, retries, delay_ms)
  local tries = retries or 20
  local delay = delay_ms or 25
  local function retarget()
    if M.retarget_to_window(anchor_win) then
      return
    end
    tries = tries - 1
    if tries > 0 then
      vim.defer_fn(retarget, delay)
    end
  end
  vim.defer_fn(retarget, 10)
end

return M
