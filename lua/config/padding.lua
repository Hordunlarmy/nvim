-- Add padding to all floating windows automatically

-- Auto-command to add padding when floating windows open
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    local win = vim.api.nvim_get_current_win()
    local config = vim.api.nvim_win_get_config(win)
    
    -- If it's a floating window, add padding
    if config.relative and config.relative ~= "" then
      -- Set buffer options for padding
      vim.bo.textwidth = 0
      
      -- Add virtual padding by adjusting window options
      pcall(vim.api.nvim_win_set_option, win, 'sidescrolloff', 4)
      pcall(vim.api.nvim_win_set_option, win, 'scrolloff', 2)
    end
  end,
})

-- Add padding to Spectre specifically
vim.api.nvim_create_autocmd("FileType", {
  pattern = "spectre_panel",
  callback = function()
    vim.bo.textwidth = 0
    local win = vim.api.nvim_get_current_win()
    pcall(vim.api.nvim_win_set_option, win, 'sidescrolloff', 4)
    pcall(vim.api.nvim_win_set_option, win, 'scrolloff', 2)
  end,
})

return {}


