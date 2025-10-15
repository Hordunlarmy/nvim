-- Quick command to rebuild LuaSnip with jsregexp
-- Run this once if you see jsregexp warnings in :checkhealth

vim.api.nvim_create_user_command('LuaSnipRebuild', function()
  vim.notify("🔨 Rebuilding LuaSnip with jsregexp...", vim.log.levels.INFO)
  
  -- Use Lazy to rebuild
  local lazy_ok, lazy = pcall(require, "lazy")
  if lazy_ok then
    lazy.build({ plugins = { "LuaSnip" }, show = true })
    vim.defer_fn(function()
      vim.notify("✅ LuaSnip rebuilt! Restart Neovim to apply changes.", vim.log.levels.INFO, { timeout = 3000 })
    end, 2000)
  else
    vim.notify("❌ Lazy not available", vim.log.levels.ERROR)
  end
end, { desc = "Rebuild LuaSnip with jsregexp" })

-- Add keybinding
vim.keymap.set('n', '<leader>uL', ':LuaSnipRebuild<CR>', 
  { noremap = true, silent = true, desc = "Rebuild LuaSnip (fix jsregexp)" })

