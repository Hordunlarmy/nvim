local function get_node_major()
  if vim.fn.executable("node") ~= 1 then
    return nil, ""
  end
  local out = vim.fn.system({ "node", "--version" })
  if vim.v.shell_error ~= 0 then
    return nil, ""
  end
  local version = vim.trim(out or "")
  local major = tonumber(version:match("^v?(%d+)"))
  return major, version
end

local config = function()
  local node_major, node_version = get_node_major()
  if not node_major or node_major < 22 then
    vim.notify(
      "Copilot disabled: Node.js 22+ required. Current version: "
      .. (node_version ~= "" and node_version or "not found"),
      vim.log.levels.WARN
    )
    return
  end

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
        accept = false,   -- DISABLED so our custom <Tab> handles acceptance
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

    copilot_node_command = "node", -- Node.js version must be >= 22
    workspace_folders = {},
    auth_provider_url = nil,
    copilot_model = "",
    disable_limit_reached_message = false,

    root_dir = function()
      local git_dir = vim.fs.find(".git", { upward = true })[1]
      if git_dir then
        return vim.fs.dirname(git_dir)
      end
      return (vim.uv and vim.uv.cwd and vim.uv.cwd()) or vim.fn.getcwd()
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

  vim.keymap.set("i", "<Tab>", function()
    local suggestion = require("copilot.suggestion")
    if suggestion.is_visible() then
      suggestion.accept()
      return ""
    end
    return "<Tab>"
  end, { expr = true, silent = true, desc = "Accept Copilot or insert Tab" })
end

return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  dependencies = "zbirenbaum/copilot-cmp",
  config = config,
  enabled = function()
    return vim.fn.executable("node") == 1
  end,
}
