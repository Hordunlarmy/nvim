
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
  markdown = {"markdownlint"},
  -- python = {'pycodestyle'},
  javascript = {'semistandard'},
}


-- semistandard config
require('lint').linters.semistandard = {
  cmd = 'semistandard',
  stdin = false,
  append_fname = false,
  args = {vim.fn.expand('%:p')},
  stream = 'stderr',
  ignore_exitcode = true,  -- Ignore the exit status of semistandard
  env = nil,
  parser = require('lint.parser').from_errorformat('semistandard')
}


