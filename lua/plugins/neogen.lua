-- Neogen - Annotation/Documentation Generator
-- Modern, fast, and supports multiple languages

return {
  "danymat/neogen",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "L3MON4D3/LuaSnip",
  },
  cmd = "Neogen",  -- Load when :Neogen command is used
  keys = {
    { "<leader>cc", desc = "Generate documentation" },
    { "<leader>cf", desc = "Generate function docs" },
  },
  config = function()
    require('neogen').setup({
      enabled = true,
      snippet_engine = "luasnip",  -- Use LuaSnip for snippets
      languages = {
        python = {
          template = {
            annotation_convention = "google",  -- Google-style docstrings for Python
          },
        },
        lua = {
          template = {
            annotation_convention = "ldoc",  -- LDoc for Lua
          },
        },
        typescript = {
          template = {
            annotation_convention = "jsdoc",  -- JSDoc for TypeScript
          },
        },
        javascript = {
          template = {
            annotation_convention = "jsdoc",  -- JSDoc for JavaScript
          },
        },
        rust = {
          template = {
            annotation_convention = "rustdoc",  -- Rustdoc for Rust
          },
        },
        go = {
          template = {
            annotation_convention = "godoc",  -- Godoc for Go
          },
        },
        c = {
          template = {
            annotation_convention = "doxygen",
          },
        },
        cpp = {
          template = {
            annotation_convention = "doxygen",
          },
        },
        java = {
          template = {
            annotation_convention = "javadoc",
          },
        },
      },
    })

    -- Keybindings for generating documentation
    local opts = { noremap = true, silent = true }
    
    -- MAIN: <leader>cc (double-tap c = Comment/docs) - Simple and works!
    vim.keymap.set("n", "<leader>cc", function() require('neogen').generate() end, 
      vim.tbl_extend("force", opts, { desc = "Generate documentation" }))
    
    -- Specific types - using <leader>c prefix (now available since we removed chmod!)
    vim.keymap.set("n", "<leader>cf", function() require('neogen').generate({ type = 'func' }) end,
      vim.tbl_extend("force", opts, { desc = "Generate function docs" }))
    
    vim.keymap.set("n", "<leader>cl", function() require('neogen').generate({ type = 'class' }) end,
      vim.tbl_extend("force", opts, { desc = "Generate class docs" }))
    
    vim.keymap.set("n", "<leader>ct", function() require('neogen').generate({ type = 'type' }) end,
      vim.tbl_extend("force", opts, { desc = "Generate type docs" }))
    
    vim.keymap.set("n", "<leader>ci", function() require('neogen').generate({ type = 'file' }) end,
      vim.tbl_extend("force", opts, { desc = "Generate file docs" }))
  end,
}

