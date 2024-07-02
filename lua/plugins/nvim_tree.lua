local config = function()
  require("nvim-tree").setup({
    filters = {
      dotfiles = false,
    },
    view = {
      adaptive_size = true,
      width = 30,
    },
    renderer = {
      highlight_opened_files = "none", -- Set to "icon", "name", or "all"
    },
    update_focused_file = {
      enable = true,
      update_cwd = true,
    },
    actions = {
      open_file = {
        quit_on_open = false,
      },
    },
    git = {
      ignore = true,
    },
  })

  -- Close editor if nvim is the last buffer
  vim.api.nvim_create_autocmd("QuitPre", {
    callback = function()
      local invalid_win = {}
      local wins = vim.api.nvim_list_wins()
      for _, w in ipairs(wins) do
        local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
        if bufname:match("NvimTree_") ~= nil then
          table.insert(invalid_win, w)
        end
      end
      if #invalid_win == #wins - 1 then
        -- Should quit, so we close all invalid windows.
        for _, w in ipairs(invalid_win) do vim.api.nvim_win_close(w, true) end
      end
    end
  })

  -- Open NvimTree on startup
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      require("nvim-tree.api").tree.open()
    end
  })

  -- Move cursor to the other buffer
  vim.cmd([[autocmd VimEnter * wincmd p]])

  -- Set termguicolors to enable highlight groups
  vim.opt.termguicolors = true

  -- nvim-tree transparent background
  vim.cmd [[hi NvimTreeNormal guibg=NONE ctermbg=NONE]]

  -- Set window separator color
  vim.cmd([[highlight WinSeparator guifg=#8B8B8B guibg=NONE]])
end

return {
  "nvim-tree/nvim-tree.lua",
  lazy = false,
  config = config,
}
