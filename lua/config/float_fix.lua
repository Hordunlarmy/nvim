-- Force floating windows to be opaque with consistent styling
-- Uses autocmd instead of monkey-patching vim.api.nvim_open_win

vim.api.nvim_create_autocmd("WinNew", {
  group = vim.api.nvim_create_augroup("FloatFix", { clear = true }),
  callback = function()
    local win = vim.api.nvim_get_current_win()
    local cfg = vim.api.nvim_win_get_config(win)
    if cfg.relative and cfg.relative ~= "" then
      vim.wo[win].winblend = 0
      vim.wo[win].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,NormalNC:NormalFloat"
      vim.wo[win].sidescrolloff = 2
    end
  end,
})

return {}
