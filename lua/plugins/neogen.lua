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
    { "<leader>cF", desc = "Generate function docs" },
  },
  config = function()
    local function clojure_docstring()
      local bufnr = vim.api.nvim_get_current_buf()
      local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
      local start_line

      -- Find the enclosing Clojure callable.  A docstring must occur directly
      -- after its name, before the argument vector, so insert it on that line.
      for line_number = cursor_line, math.max(1, cursor_line - 250), -1 do
        local line = vim.api.nvim_buf_get_lines(bufnr, line_number - 1, line_number, false)[1]
        if line and line:match("^%s*%(defn[%w%-%?!]*%s+")
          or line and line:match("^%s*%(defmacro%s+")
          or line and line:match("^%s*%(defmulti%s+") then
          start_line = line_number
          break
        end
      end

      if not start_line then
        vim.notify("Place the cursor inside a defn, defmacro, or defmulti first", vim.log.levels.WARN)
        return
      end

      local line = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, start_line, false)[1]
      local _, name_end, _, name = line:find("(%(defn[%w%-%?!]*%s+)([%w%-%?!%*/_]+)")
      if not name_end then
        _, name_end, _, name = line:find("(%(defmacro%s+)([%w%-%?!%*/_]+)")
      end
      if not name_end then
        _, name_end, _, name = line:find("(%(defmulti%s+)([%w%-%?!%*/_]+)")
      end
      if not name_end or not name then
        vim.notify("Could not identify the Clojure definition name", vim.log.levels.WARN)
        return
      end

      if line:sub(name_end + 1):match("^%s*\"") then
        vim.notify("This Clojure definition already has a docstring", vim.log.levels.INFO)
        return
      end

      vim.api.nvim_buf_set_text(bufnr, start_line - 1, name_end, start_line - 1, name_end, {
        string.format(' "TODO: Describe `%s`."', name),
      })
      vim.api.nvim_win_set_cursor(0, { start_line, name_end + 8 })
      vim.cmd("startinsert")
    end

    local function generate_documentation(opts)
      if vim.bo.filetype == "clojure" or vim.bo.filetype == "clojurescript" or vim.bo.filetype == "clojurec" then
        return clojure_docstring()
      end
      require("neogen").generate(opts)
    end

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
    vim.keymap.set("n", "<leader>cc", generate_documentation,
      vim.tbl_extend("force", opts, { desc = "Generate documentation" }))
    
    -- Specific types - using <leader>c prefix (now available since we removed chmod!)
    vim.keymap.set("n", "<leader>cF", function() generate_documentation({ type = 'func' }) end,
      vim.tbl_extend("force", opts, { desc = "Generate function docs" }))
    
    vim.keymap.set("n", "<leader>cl", function() require('neogen').generate({ type = 'class' }) end,
      vim.tbl_extend("force", opts, { desc = "Generate class docs" }))
    
    vim.keymap.set("n", "<leader>ct", function() require('neogen').generate({ type = 'type' }) end,
      vim.tbl_extend("force", opts, { desc = "Generate type docs" }))
    
    vim.keymap.set("n", "<leader>ci", function() require('neogen').generate({ type = 'file' }) end,
      vim.tbl_extend("force", opts, { desc = "Generate file docs" }))
  end,
}
