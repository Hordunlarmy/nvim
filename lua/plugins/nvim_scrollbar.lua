-- nvim-scrollbar: Visual scrollbar for all windows
return {
  "petertriho/nvim-scrollbar",
  config = function()
    require("scrollbar").setup({
      show = true,
      show_in_active_only = false,
      set_highlights = true,
      handle = {
        text = " ",
        color = nil,
        highlight = "CursorColumn",
      },
      marks = {
        Search = { text = { "-", "=" }, priority = 0, color = nil },
        Error = { text = { "-", "=" }, priority = 1, color = nil },
        Warn = { text = { "-", "=" }, priority = 2, color = nil },
        Info = { text = { "-", "=" }, priority = 3, color = nil },
        Hint = { text = { "-", "=" }, priority = 4, color = nil },
        Misc = { text = { "-", "=" }, priority = 5, color = nil },
      },
      excluded_buftypes = {
        "terminal",
      },
      excluded_filetypes = {
        "prompt",
        "TelescopePrompt",
        "alpha",
        -- Include notify for scrollbar support
      },
      autocmd = {
        render = {
          "BufWinEnter",
          "TabEnter",
          "TermEnter",
          "WinEnter",
          "CmdwinLeave",
          "TextChanged",
          "VimResized",
          "WinScrolled",
        },
        clear = {
          "BufWinLeave",
          "TabLeave",
          "TermLeave",
          "WinLeave",
        },
      },
      handlers = {
        cursor = true,
        diagnostic = true,
        gitsigns = true,
        handle = true,
        search = false,
      },
    })
  end,
}

