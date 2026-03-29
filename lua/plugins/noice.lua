-- Route Neovim messages/errors through Noice -> notify backend.
-- notify is then routed into the lualine ticker by config/suppress_warnings.lua.
return {
  "folke/noice.nvim",
  lazy = false,
  opts = {
    messages = {
      enabled = true,
      view = "notify",
      view_error = "notify",
      view_warn = "notify",
      view_history = "messages",
    },
    notify = {
      -- Keep vim.notify ownership in our ticker router.
      enabled = false,
    },
    routes = {
      {
        filter = { event = "msg_showmode" },
        opts = { skip = true },
      },
    },
    views = {
      history_win = {
        backend = "popup",
        relative = "editor",
        enter = true,
        position = { row = "50%", col = "50%" },
        size = { width = 0.90, height = 0.75 },
        border = { style = "rounded" },
      },
    },
    lsp = {
      progress = { enabled = false },
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
      hover = { enabled = false },
    },
    commands = {
      history = {
        view = "history_win",
        opts = { enter = true, format = "details" },
      },
    },
    presets = {
      bottom_search = true,
      command_palette = true,
      long_message_to_split = false,
      inc_rename = false,
      lsp_doc_border = false,
    },
  },
  config = function(_, opts)
    require("noice").setup(opts)
  end,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },
}
