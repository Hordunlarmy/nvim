local config = function()
  require("copilot").setup({
    panel = {
      enabled = true,
      auto_refresh = false,
      keymap = {
        jump_prev = "[[",
        jump_next = "]]",
        accept = "<CR>",
        refresh = "gr",
        open = "<M-CR>",
      },
      layout = {
        position = "bottom",
        ratio = 0.4,
      },
    },
    suggestion = {
      enabled = true,
      auto_trigger = true,
      hide_during_completion = true,
      debounce = 75,
      trigger_on_accept = true,
      keymap = {
        accept = "<Tab>",
        accept_word = false,
        accept_line = false,
        next = "<M-]>",
        prev = "<M-[>",
        dismiss = "<C-]>",
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
    },
    copilot_node_command = "node", -- Node.js version must be > 20
    workspace_folders = {},
    auth_provider_url = nil,
    copilot_model = "",
    disable_limit_reached_message = false,
    root_dir = function()
      return vim.fs.dirname(vim.fs.find(".git", { upward = true })[1])
    end,
    should_attach = function(_, _)
      if not vim.bo.buflisted then return false end
      if vim.bo.buftype ~= "" then return false end
      return true
    end,
    server = {
      type = "nodejs",
      custom_server_filepath = nil,
    },
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

