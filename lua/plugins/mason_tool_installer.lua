-- Auto-install formatters, linters, and DAP servers
return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  dependencies = { "williamboman/mason.nvim" },
  event = "VeryLazy",
  opts = {
    ensure_installed = {
      -- Formatters
      "prettier",     -- JS/TS/JSON/CSS/HTML formatter
      "stylua",       -- Lua formatter
      "black",        -- Python formatter
      "isort",        -- Python import sorter
      "shfmt",        -- Shell script formatter
      
      -- Linters
      "eslint_d",     -- JS/TS linter (fast)
      "pylint",       -- Python linter
      "shellcheck",   -- Shell script linter
      "markdownlint", -- Markdown linter
      
      -- DAP (Debuggers)
      "debugpy",      -- Python debugger
      
      -- Optional (uncomment if needed)
      -- "gofumpt",      -- Go formatter
      -- "golangci-lint",-- Go linter
      -- "phpcs",        -- PHP linter
      -- "rustywind",    -- Tailwind CSS sorter
    },
    
    auto_update = false,
    run_on_start = true,
    start_delay = 3000, -- 3 second delay
    debounce_hours = 5, -- at least 5 hours between attempts
  },
}


