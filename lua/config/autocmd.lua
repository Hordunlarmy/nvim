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

-- Close editor if nvim-tree is the last buffer
vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("NvimTreeClose", {clear = true}),
  pattern = "NvimTree_*",
  callback = function()
    local layout = vim.api.nvim_call_function("winlayout", {})
    if layout[1] == "leaf" and layout[2] and type(layout[2]) == "number" then
      local win = layout[2]
      if vim.api.nvim_win_is_valid(win) then
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "NvimTree" and layout[3] == nil then 
          vim.cmd("confirm quit") 
        end
      end
    end
  end
})

-- Open NvimTree on startup and focus main window
vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("NvimTreeAutoOpen", { clear = true }),
  callback = function()
    vim.defer_fn(function()
      local ok, api = pcall(require, "nvim-tree.api")
      if ok then
        api.tree.open()
        vim.cmd("wincmd l")
      end
    end, 50)
  end,
})

-- Clojure REPL auto-start is handled by Conjure's native auto_repl feature.
