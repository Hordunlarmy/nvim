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

-- NvimTree lifecycle is managed in plugin configs; avoid duplicate global handlers here.

-- Clojure REPL auto-start is handled by Conjure's native auto_repl feature.

-- Show file-save confirmation in the statusline ticker.
vim.api.nvim_create_autocmd("BufWritePost", {
  group = vim.api.nvim_create_augroup("StatuslineSaveNotice", { clear = true }),
  callback = function(args)
    local ok_ticker, ticker = pcall(require, "util.notify_ticker")
    if not ok_ticker then
      return
    end
    local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(args.buf), ":t")
    if name == "" then
      name = "[No Name]"
    end
    ticker.push("Saved " .. name, vim.log.levels.INFO, { timeout = 1800 })
  end,
})
