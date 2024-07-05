local config = function()
  require("copilot").setup({
    panel = {
      close_on_escape = true,
      enabled = true,
      auto_refresh = false,
      keymap = {
        jump_prev = "[[",
        jump_next = "]]",
        accept = "<CR>",
        refresh = "gr",
        open = "<M-m>",
      },
      layout = {
        position = "bottom", -- | top | left | right
        ratio = 0.4,
      },
    },
    suggestion = {
      enabled = true,
      auto_trigger = true,
      debounce = 75,
      keymap = {
        accept = "<M-CR>",
        accept_word = false,
        accept_line = false,
        next = "<M-Right>",
        prev = "<M-Left>",
        dismiss = "<M-q>",
      },
    },
    filetypes = {
      yaml = false,
      markdown = false,
      help = false,
      gitcommit = false,
      gitrebase = false,
      hgcommit = false,
      svn = false,
      cvs = false,
      ["."] = false,
    },
    copilot_node_command = "node", -- Node.js version must be > 16.x
    server_opts_overrides = {},
  })
  require("copilot_cmp").setup({
    formatters = {
      insert_text = require("copilot_cmp.format").remove_existing,
    },
  })
end


return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  dependencies = "zbirenbaum/copilot-cmp",

  config = config,
  lazy = false,
}
