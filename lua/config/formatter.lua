---------------Formatter----------------------------
-----------------------------------------------------

require("formatter").setup({
  filetype = {
    python = {
      function()
        return {
          exe = "flake8",
          args = {"-"},
          stdin = true,
        }
      end,
      function()
        return {
          exe = "isort",
          args = { "--stdout", "--filename", vim.api.nvim_buf_get_name(0), "-" },
          stdin = true
        }
      end,
      function()
        return {
          exe = "black",
          args = {"-"},
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
    html, htmldjango = {
      function()
        return {
          exe = "htmlbeautifier",
          stdin = true,
        }
      end,
    },
    -- other file types and configurations
    -- ...
  },
})
