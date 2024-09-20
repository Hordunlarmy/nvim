local config = function()

  require("formatter").setup({
    logging = false,
    filetype = {
      lua = {
        function()
          return {
            exe = "luafmt",
            args = { "--indent-count", 2, "--stdin" },
            stdin = true,
          }
        end,
      },
      python = {
        function()
          return {
            exe = "black",
            args = { "-", "--line-length 79" },
            stdin = true,
          }
        end,
        function()
          return {
            exe = "isort",
            args = { "-" },
            stdin = true,
          }
        end,
      },
      typescript = {
        function()
          return {
            exe = "prettier",
            args = { "--stdin-filepath", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)) },
            stdin = true,
          }
        end,
      },
      javascript = {
      function()
        return {
          exe = "prettier",
          args = {"--stdin-filepath", vim.fn.shellescape(vim.api.nvim_buf_get_name(0)),},
          stdin = true,
          --cwd = vim.fn.expand('%:p:h'),
        }
      end,
    },
      markdown = {
        function()
          return {
            exe = "prettier",
            args = { "--stdin-filepath", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)) },
            stdin = true,
          }
        end,
      },
      html = {
        function()
          return {
            exe = "prettier",
            args = { "--stdin-filepath", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)) },
            stdin = true,
          }
        end,
      },
      css = {
        function()
          return {
            exe = "prettier",
            args = { "--stdin-filepath", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)) },
            stdin = true,
          }
        end,
      },
      sh = {
        function()
          return {
            exe = "shfmt",
            args = { "-" },
            stdin = true,
          }
        end,
      },
      dockerfile = {
        function()
          return {
            exe = "dockerfile_lint",
            args = { "-" },
            stdin = true,
          }
        end,
      },
    },
  })
end

-- vim.api.nvim_set_keymap("n", "<leader>f", ":Format<CR>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("n", "<leader>F", ":FormatWrite<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Esc>', [[:Format<CR>]], { noremap = true, silent = true })

return {
  "mhartington/formatter.nvim",
  config = config,
  lazy = false,
}
