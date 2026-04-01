-- conform.nvim: Auto-formatting on save
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  init = function()
    vim.fn.mkdir(vim.fn.stdpath("cache") .. "/conform", "p")
  end,
  keys = {
    {
      "<leader>cf",
      function()
        local ok, conform = pcall(require, "conform")
        if not ok then
          return
        end
        conform.format({ async = true, lsp_format = "fallback", quiet = true })
      end,
      mode = "n",
      desc = "Format buffer",
    },
    {
      "<leader>cr",
      function()
        local ok, conform = pcall(require, "conform")
        if not ok then
          return
        end
        local line = vim.api.nvim_win_get_cursor(0)[1]
        conform.format({
          async = true,
          lsp_format = "fallback",
          quiet = true,
          range = {
            start = { line, 0 },
            ["end"] = { line, math.max(vim.fn.col("$") - 1, 0) },
          },
        })
      end,
      mode = "n",
      desc = "Format current line",
    },
    {
      "<leader>cr",
      function()
        local ok, conform = pcall(require, "conform")
        if not ok then
          return
        end
        local start_line, start_col = unpack(vim.api.nvim_buf_get_mark(0, "<"))
        local end_line, end_col = unpack(vim.api.nvim_buf_get_mark(0, ">"))
        if start_line == 0 or end_line == 0 then
          return
        end
        if end_line < start_line or (end_line == start_line and end_col < start_col) then
          start_line, end_line = end_line, start_line
          start_col, end_col = end_col, start_col
        end
        conform.format({
          async = true,
          lsp_format = "fallback",
          quiet = true,
          range = {
            start = { start_line, start_col },
            ["end"] = { end_line, end_col },
          },
        })
      end,
      mode = "v",
      desc = "Format selection",
    },
    {
      "<Esc>",
      function()
        local function is_format_target(bufnr)
          if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
            return false
          end
          if not vim.bo[bufnr].modifiable or vim.bo[bufnr].readonly then
            return false
          end
          if vim.bo[bufnr].buftype ~= "" then
            return false
          end
          local ft = vim.bo[bufnr].filetype
          if ft == "aerial" or ft == "NvimTree" or ft == "alpha" or ft == "help" or ft == "qf" then
            return false
          end
          return true
        end

        -- Leave insert mode first, then format current buffer when applicable.
        local win_cfg = vim.api.nvim_win_get_config(0)
        local bufnr = vim.api.nvim_get_current_buf()
        if win_cfg.relative ~= "" or not is_format_target(bufnr) then
          return "<Esc>"
        end

        local ok, conform = pcall(require, "conform")
        if not ok then
          return "<Esc>"
        end

        local formatters, lsp = conform.list_formatters_to_run(bufnr)
        if #formatters > 0 or lsp then
          vim.schedule(function()
            conform.format({
              bufnr = bufnr,
              async = true,
              lsp_format = "fallback",
              quiet = true,
            })
          end)
        end

        return "<Esc>"
      end,
      mode = "i",
      expr = true,
      desc = "Leave insert + format buffer",
    },
    {
      "<Esc>",
      function()
        local function is_format_target(bufnr)
          if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
            return false
          end
          if not vim.bo[bufnr].modifiable or vim.bo[bufnr].readonly then
            return false
          end
          if vim.bo[bufnr].buftype ~= "" then
            return false
          end
          local ft = vim.bo[bufnr].filetype
          if ft == "aerial" or ft == "NvimTree" or ft == "alpha" or ft == "help" or ft == "qf" then
            return false
          end
          return true
        end

        local ok, conform = pcall(require, "conform")
        if not ok then
          return
        end

        -- Keep Esc formatting for regular file buffers only.
        local win_cfg = vim.api.nvim_win_get_config(0)
        local bufnr = vim.api.nvim_get_current_buf()
        if win_cfg.relative ~= "" or not is_format_target(bufnr) then
          return
        end

        local formatters, lsp = conform.list_formatters_to_run(bufnr)
        if #formatters == 0 and not lsp then
          return
        end

        conform.format({
          bufnr = bufnr,
          async = true,
          lsp_format = "fallback",
          quiet = true,
        })
      end,
      mode = "n",
      desc = "Format buffer (Esc)",
    },
  },
  opts = {
    notify_on_error = false,
    notify_no_formatters = false,
    default_format_opts = {
      lsp_format = "fallback",
      quiet = true,
    },
    formatters_by_ft = {
      -- Clojure
      clojure = { "zprint" },
      cljc = { "zprint" },
      cljs = { "zprint" },
      edn = { "zprint" },
      
      -- Python
      python = { "isort", "black" },
      
      -- JavaScript/TypeScript
      javascript = { "prettier" },
      typescript = { "prettier" },
      javascriptreact = { "prettier" },
      typescriptreact = { "prettier" },
      
      -- Go
      go = { "gofmt" },
      
      -- Rust
      rust = { "rustfmt" },
      
      -- Web
      html = { "prettier" },
      css = { "prettier" },
      json = { "prettier" },
      yaml = { "prettier" },
      markdown = { "prettier" },
    },
    format_on_save = false,
    formatters = {
      zprint = {
        command = vim.fn.stdpath("data") .. "/mason/bin/zprint",
        args = {},
        stdin = true,
      },
    },
  },
}
