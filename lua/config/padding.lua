-- Add padding to floating windows and special panels

local padding_group = vim.api.nvim_create_augroup("FloatPadding", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = padding_group,
  pattern = "*",
  callback = function()
    local win = vim.api.nvim_get_current_win()
    local cfg = vim.api.nvim_win_get_config(win)
    if cfg.relative and cfg.relative ~= "" then
      vim.wo[win].sidescrolloff = 4
      vim.wo[win].scrolloff = 2
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = padding_group,
  pattern = "spectre_panel",
  callback = function()
    local win = vim.api.nvim_get_current_win()
    vim.wo[win].sidescrolloff = 4
    vim.wo[win].scrolloff = 2
  end,
})

return {}


