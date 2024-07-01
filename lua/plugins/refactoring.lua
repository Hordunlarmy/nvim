local config = function()
  require('refactoring').setup({
    -- General refactoring options
    refactor = {
      -- Example keymaps for refactoring actions
      rename = {
        enable = true,
        keymaps = {
          noremap = true,
          ["<leader>rn"] = "refactoring#rename",
        },
      },
      extract_function = {
        enable = true,
        keymaps = {
          noremap = true,
          ["<leader>ef"] = "refactoring#extract_function",
        },
      },
      extract_variable = {
        enable = true,
        keymaps = {
          noremap = true,
          ["<leader>ev"] = "refactoring#extract_variable",
        },
      },
      inline_variable = {
        enable = true,
        keymaps = {
          noremap = true,
          ["<leader>iv"] = "refactoring#inline_variable",
        },
      },
    },

    -- Language-specific refactoring options
    refactor_language = {
      ["python"] = {
        rename = {
          enable = true,
          types = { "variable", "function", "method" },
        },
      },
      ["javascript"] = {
        rename = {
          types = { "variable", "parameter", "function", "method" },
        },
      },
      -- Additional languages can be added here
    },
  })
end

return {
  "theprimeagen/refactoring.nvim",
  dependencies = {
    {"nvim-lua/plenary.nvim"},
    {"nvim-treesitter/nvim-treesitter"}
  },

  config = config,
}
