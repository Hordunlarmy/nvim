-- conform.nvim: Auto-formatting on save
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
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
      mode = "",
      desc = "Format buffer",
    },
    {
      "<Esc>",
      function()
        -- Leave insert mode first, then format current buffer when applicable.
        local win_cfg = vim.api.nvim_win_get_config(0)
        if win_cfg.relative ~= "" or vim.bo.buftype ~= "" then
          return "<Esc>"
        end

        local ok, conform = pcall(require, "conform")
        if not ok then
          return "<Esc>"
        end

        local bufnr = vim.api.nvim_get_current_buf()
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
        local ok, conform = pcall(require, "conform")
        if not ok then
          return
        end

        -- Keep Esc formatting for regular file buffers only.
        local win_cfg = vim.api.nvim_win_get_config(0)
        if win_cfg.relative ~= "" then
          return
        end
        if vim.bo.buftype ~= "" then
          return
        end

        local bufnr = vim.api.nvim_get_current_buf()
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
      clojure = { "cljfmt" },
      edn = { "cljfmt" },
      
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
      cljfmt = {
        command = "cljfmt",
        args = { "fix", "$FILENAME" },
        stdin = false,
      },
    },
  },
}
