return {
  "nvimdev/lspsaga.nvim",
  lazy = false,
  event = "LspAttach",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("lspsaga").setup({
      ui = {
        border = "rounded",  -- White border
        winblend = 0,  -- Opaque
        code_action = " ",
      },
      hover = {
        max_width = 0.6,
        max_height = 0.8,
        open_link = "gx",
        open_cmd = "!xdg-open",
      },
      definition = {
        width = 0.6,
        height = 0.5,
        keys = {
          edit = "<CR>",
          vsplit = "s",
          split = "i",
          quit = "q",
        },
      },
      symbol_in_winbar = {
        enable = false,
      },
      lightbulb = {
        enable = false,
        sign = false,
      },
      outline = {
        win_width = 30,
        auto_preview = false,
      },
      beacon = {
        enable = true,
        frequency = 7,
      },
      diagnostic = {
        on_insert = false,
        on_insert_follow = false,
      },
      finder = {
        max_height = 0.6,
        keys = {
          toggle_or_open = "<CR>",
          vsplit = "s",
          split = "i",
          quit = "q",
        },
      },
    })
  end,
}
