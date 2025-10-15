-- project.nvim: Project management (DISABLED - conflicts with nvim-tree)
return {
  "ahmedkhalf/project.nvim",
  enabled = false,  -- Disabled to prevent conflicts
  event = "VeryLazy",
  keys = {
    { "<leader>fp", "<cmd>Telescope projects<cr>", desc = "Projects" },
  },
  opts = {
    manual_mode = false,
    detection_methods = { "lsp", "pattern" },
    patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json", "go.mod" },
    ignore_lsp = {},
    exclude_dirs = {},
    show_hidden = false,
    silent_chdir = true,
    scope_chdir = "global",
    datapath = vim.fn.stdpath("data"),
  },
  config = function(_, opts)
    require("project_nvim").setup(opts)
    require("telescope").load_extension("projects")
  end,
}

