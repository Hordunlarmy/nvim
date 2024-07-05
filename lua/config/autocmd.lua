----------------Highlight Yank------------------
------------------------------------------------
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

vim.api.nvim_create_autocmd("BufWritePost", {
  callback = function()
    -- Get the current buffer's file name
    local filename = vim.fn.expand('%:t')
    -- Print the custom message
    print("  " .. filename .. " saved successfully!")
  end
})
