-- Force all floating windows to be opaque, centered, with white borders and padding

-- Override floating window defaults
local orig_nvim_open_win = vim.api.nvim_open_win
vim.api.nvim_open_win = function(buffer, enter, config)
  -- Ensure floating windows are opaque with white borders
  if config.relative and config.relative ~= "" then
    config.border = config.border or "rounded"  -- White rounded border
    
    -- Force centering if not explicitly positioned
    if not config.row or not config.col then
      local width = config.width or 80
      local height = config.height or 20
      config.row = math.floor((vim.o.lines - height) / 2)
      config.col = math.floor((vim.o.columns - width) / 2)
    end
  end
  
  local win = orig_nvim_open_win(buffer, enter, config)
  
  -- Force opaque background with theme color and padding on all floating windows
  if config.relative and config.relative ~= "" then
    pcall(vim.api.nvim_win_set_option, win, 'winblend', 0)
    pcall(vim.api.nvim_win_set_option, win, 'winhl', 'Normal:NormalFloat,FloatBorder:FloatBorder,NormalNC:NormalFloat')
    
    -- Add padding by setting window options
    pcall(vim.api.nvim_win_set_option, win, 'sidescrolloff', 2)
  end
  
  return win
end

return {}

