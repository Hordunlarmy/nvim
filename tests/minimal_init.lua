-- Minimal init for running tests in a headless Neovim instance.
-- Loads the full user config so tests run against the real setup.

-- Load the full config (bootstraps lazy.nvim, config, and all plugins)
local ok, err = pcall(dofile, vim.fn.expand("~/.config/nvim/init.lua"))
if not ok then
  print("WARNING: Config load error: " .. tostring(err))
end

-- Wait for lazy.nvim to register all plugins (up to 5s)
vim.wait(5000, function()
  local lazy_ok, lazy = pcall(require, "lazy")
  if not lazy_ok then return false end
  local stats = lazy.stats()
  return stats and stats.count and stats.count > 0
end, 100)

-- Force-load plugins that tests need to inspect
pcall(function()
  require("lazy").load({ plugins = {
    "plenary.nvim",
    "nvim-lspconfig",
    "nvim-treesitter",
    "mason.nvim",
    "mason-lspconfig.nvim",
    "nvim-cmp",
    "formatter.nvim",
    "efmls-configs-nvim",
    "rainbow-delimiters.nvim",
  }})
end)
