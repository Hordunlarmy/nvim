
-------------- LSP --------------
---------------------------------
require("mason").setup()
require("mason-lspconfig").setup {
    ensure_installed = { "lua_ls" },
}
require('refactoring').setup()

------- NULL-LS LINTS --------------
------------------------------------

-- Set up linters and formatters
-- local null_ls = require('null-ls')

--null_ls.setup({
  --sources = {
    -- Lua formatter
    --null_ls.builtins.formatting.stylua,

    -- ESLint linter
    --null_ls.builtins.diagnostics.eslint_d,

    -- Prettier formatter
    --null_ls.builtins.formatting.prettier,

    -- shell script formatting
    --null_ls.builtins.formatting.shfmt,

    -- shell script diagnostics
    --null_ls.builtins.diagnostics.shellcheck,

    -- Flake8 linter
    --null_ls.builtins.diagnostics.flake8,

    -- Refactoring Code_action
    --null_ls.builtins.code_actions.refactoring

    -- Betty linter
    -- null_ls.builtins.diagnostics.betty,
  --},
--})
--
--------------------Nvim-lint------------------------------
----------------------------------------------------------
require('lint').linters_by_ft = {
  markdown = {'vale', "markdownlint"},
  python = {'flake8'},
  javascript = {'eslint'}, 
  vint = {'vint'},

}

---------------Formatter----------------------------
-----------------------------------------------------

require("formatter").setup({
  filetype = {
    python = {
      function()
        return {
          exe = "autopep8",
          args = {"-"},
          stdin = true,
        }
      end,
    },
    javascript = {
        function()
          return {
            exe = "semistandard",
            args = {"--fix"},
            stdin = false,
            cwd = vim.fn.expand('%:p:h'),
          }
        end,
      },
    -- other file types and configurations
    -- ...
  },
})
