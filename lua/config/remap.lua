---@diagnostic disable: inject-field
-- change leader key to space
vim.g.mapleader = " "

-- GLOBAL diagnostic keybindings (work everywhere, not just LSP buffers)
vim.keymap.set('n', '<leader>do', function()
	local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line('.') - 1 })
	if #diagnostics == 0 then
		vim.notify("No diagnostics at cursor", vim.log.levels.WARN)
		return
	end
	
	-- Format diagnostic text
	local lines = {}
	for i, diag in ipairs(diagnostics) do
		local severity = ({ "ERROR", "WARN", "INFO", "HINT" })[diag.severity] or "INFO"
		table.insert(lines, string.format("[%s] %s", severity, diag.source or "LSP"))
		table.insert(lines, diag.message)
		if i < #diagnostics then
			table.insert(lines, "")
		end
	end
	
	-- Create buffer with diagnostic text
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
	vim.bo[buf].buftype = "nofile"
	
	-- Calculate centered position
	local width = 70
	local height = #lines + 2
	local win_width = vim.o.columns
	local win_height = vim.o.lines
	local row = math.floor((win_height - height) / 2)
	local col = math.floor((win_width - width) / 2)
	
	-- Create floating window
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		focusable = true,
		zindex = 100,  -- High z-index to appear on top
	})
	
	-- Set window options for visibility
	vim.wo[win].wrap = true
	vim.wo[win].linebreak = true
	vim.wo[win].cursorline = true
	
	-- Use theme's normal float colors (matches other popups)
	-- No custom highlighting - let it inherit from your theme
	
	-- Close with q or Esc
	vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = buf, nowait = true })
	vim.keymap.set('n', '<Esc>', '<cmd>close<cr>', { buffer = buf, nowait = true })
	
	-- Quick fix with 'f' key (opens code actions)
	vim.keymap.set('n', 'f', function()
		vim.api.nvim_win_close(win, true)  -- Close popup first
		vim.defer_fn(function()
			vim.cmd('Lspsaga code_action')  -- Open code actions
		end, 100)
	end, { buffer = buf, nowait = true, desc = "Quick fix (code action)" })
	
	-- Close when clicking outside the popup
	vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
		buffer = buf,
		once = true,
		callback = function()
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_close(win, true)
			end
		end,
	})
	
	-- Popup opened silently
end, { noremap = true, silent = false, desc = "Show cursor diagnostic (focusable popup)" })

vim.keymap.set('n', '<leader>dO', function()
	-- Get ALL diagnostics on the line
	local line = vim.fn.line('.') - 1
	local diagnostics = vim.diagnostic.get(0, { lnum = line })
	if #diagnostics == 0 then
		vim.notify("No diagnostics on line", vim.log.levels.WARN)
		return
	end
	
	-- Format diagnostic text
	local lines = {}
	table.insert(lines, "=== LINE DIAGNOSTICS ===")
	table.insert(lines, "")
	for i, diag in ipairs(diagnostics) do
		local severity = ({ "ERROR", "WARN", "INFO", "HINT" })[diag.severity] or "INFO"
		table.insert(lines, string.format("[%s] %s", severity, diag.source or "LSP"))
		table.insert(lines, diag.message)
		if i < #diagnostics then
			table.insert(lines, "")
		end
	end
	
	-- Create buffer
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
	vim.bo[buf].buftype = "nofile"
	
	-- Calculate centered position
	local width = 70
	local height = #lines + 2
	local win_width = vim.o.columns
	local win_height = vim.o.lines
	local row = math.floor((win_height - height) / 2)
	local col = math.floor((win_width - width) / 2)
	
	-- Create floating window
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		focusable = true,
		zindex = 100,
	})
	
	-- Set window options
	vim.wo[win].wrap = true
	vim.wo[win].linebreak = true
	vim.wo[win].cursorline = true
	
	-- Use theme's normal float colors (matches other popups)
	-- No custom highlighting - let it inherit from your theme
	
	-- Close keybindings
	vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = buf, nowait = true })
	vim.keymap.set('n', '<Esc>', '<cmd>close<cr>', { buffer = buf, nowait = true })
	
	-- Quick fix with 'f' key (opens code actions)
	vim.keymap.set('n', 'f', function()
		vim.api.nvim_win_close(win, true)  -- Close popup first
		vim.defer_fn(function()
			vim.cmd('Lspsaga code_action')  -- Open code actions
		end, 100)
	end, { buffer = buf, nowait = true, desc = "Quick fix (code action)" })
	
	-- Close when clicking outside the popup
	vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
		buffer = buf,
		once = true,
		callback = function()
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_close(win, true)
			end
		end,
	})
	
	-- Popup opened silently
end, { noremap = true, silent = false, desc = "Show line diagnostics (focusable popup)" })

-- GLOBAL code action keybinding (works everywhere, not just LSP buffers)
vim.keymap.set('n', '<leader>ca', '<cmd>Lspsaga code_action<CR>', 
	{ noremap = true, silent = true, desc = "Code actions" })

-- map explorer command to make it easier to open
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- moving selection up and down (intelligently)
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- keep cursor in center while jumping half pages
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- better replace: doesn't overwrite your copy buffer when you use it
vim.keymap.set("x", "<leader>p", '"_dP')

-- ability to copy to system clipboard
vim.keymap.set("n", "<leader>y", '"+y')
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>Y", '"+Y')

-- ability to delete line without copying (use dd for delete - double tap d)
vim.keymap.set("n", "<leader>dd", '"_dd', { desc = "Delete line without copying" })
vim.keymap.set("v", "<leader>dd", '"_d', { desc = "Delete without copying" })
-- Also keep the old _ register mapping for operators
vim.keymap.set("n", "<leader>x", '"_d', { desc = "Delete (operator)" })

-- move between splits more easily
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- resize panes more easily
vim.keymap.set("n", "<C-Left>", ":vertical resize +3<CR>", { silent = true, noremap = true })
vim.keymap.set("n", "<C-Right>", ":vertical resize -3<CR>", { silent = true, noremap = true })
vim.keymap.set("n", "<C-Up>", ":resize +3<CR>", { silent = true, noremap = true })
vim.keymap.set("n", "<C-Down>", ":resize -3<CR>", { silent = true, noremap = true })

-- Set esc to jj (commented out - using normal ESC)
-- vim.keymap.set("i", "jj", "<ESC>")

-- remap quit, save and save&&quit command
-- Enhanced quit - auto-closes if only tree/aerial remain
vim.keymap.set('n', 'qq', function()
  -- Close current buffer
  vim.cmd('q!')
  -- Check if should auto-close
  vim.defer_fn(function()
    require('config.auto_close')
    vim.cmd('CloseIfEmpty')
  end, 100)
end, { silent = true, desc = "Quit and auto-close if empty" })

vim.keymap.set('n', 'wq', ':wq!<CR>', { silent = true })
vim.keymap.set('n', 'ww', ':w<CR>', { silent = true })


-- -- Code_Runner
vim.keymap.set('n', '<leader>r', ':RunCode<CR>', { noremap = true, silent = false })
vim.keymap.set('n', '<leader>rf', ':RunFile<CR>', { noremap = true, silent = false })
vim.keymap.set('n', '<leader>rft', ':RunFile tab<CR>', { noremap = true, silent = false })
vim.keymap.set('n', '<leader>rp', ':RunProject<CR>', { noremap = true, silent = false })
vim.keymap.set('n', '<leader>rc', ':RunClose<CR>', { noremap = true, silent = false })
vim.keymap.set('n', '<leader>crf', ':CRFiletype<CR>', { noremap = true, silent = false })
vim.keymap.set('n', '<leader>crp', ':CRProjects<CR>', { noremap = true, silent = false })

-- ⚡ RELOAD EVERYTHING - Config + Environment Variables
_G.reload_all = function()
  vim.notify("🔄 Reloading environment + config...", vim.log.levels.INFO)
  
  -- 1. Directly read and parse vault cache file
  local vault_cache = vim.fn.expand("~/.vault_keys_cache")
  local file = io.open(vault_cache, "r")
  
  if file then
    local loaded_keys = 0
    for line in file:lines() do
      -- Parse KEY="value" format
      local key, value = line:match('^([%w_]+)="(.*)"$')
      if key and value and value ~= "" then
        -- Load the key as-is first
        vim.env[key] = value
        loaded_keys = loaded_keys + 1
        
        -- Also create _API_KEY versions for compatibility
        if key == "GEMINI_KEY" then
          vim.env.GEMINI_API_KEY = value
        elseif key == "OPENAI_KEY" then
          vim.env.OPENAI_API_KEY = value
        elseif key == "ANTHROPIC_KEY" then
          vim.env.ANTHROPIC_API_KEY = value
        elseif key == "AIHUBMIX_KEY" then
          vim.env.AIHUBMIX_API_KEY = value
        end
      end
    end
    file:close()
    
    if loaded_keys > 0 then
      vim.notify(string.format("🔑 Loaded %d API keys", loaded_keys), vim.log.levels.INFO, { timeout = 1000 })
    else
      vim.notify("⚠️ No keys found in vault cache", vim.log.levels.WARN)
    end
  else
    vim.notify("❌ Could not read vault cache", vim.log.levels.ERROR)
  end
  
  -- 2. Clear loaded Lua modules
  for name, _ in pairs(package.loaded) do
    if name:match('^config') or name:match('^plugins') or name:match('^util') then
      package.loaded[name] = nil
    end
  end
  
  -- 3. Source Neovim config
  vim.cmd('source ~/.config/nvim/init.lua')
  
  vim.notify("✨ Everything reloaded!", vim.log.levels.INFO, { timeout = 1500 })
end

-- Simple config-only reload (no env vars)
_G.reload_config = function()
  for name, _ in pairs(package.loaded) do
    if name:match('^config') or name:match('^plugins') or name:match('^util') then
      package.loaded[name] = nil
    end
  end
  vim.cmd('source ~/.config/nvim/init.lua')
  vim.notify("✨ Config reloaded!", vim.log.levels.INFO, { timeout = 1500 })
end

-- Keybindings
vim.keymap.set('n', '<F5>', _G.reload_all, { noremap = true, silent = true, desc = "Reload config + env vars" })
vim.keymap.set('n', '<leader>R', _G.reload_all, { noremap = true, silent = true, desc = "Reload all" })
vim.keymap.set('n', '<leader>so', _G.reload_config, { noremap = true, silent = true, desc = "Reload config only" })

-- Debug: Check all loaded API keys
vim.keymap.set('n', '<leader>sk', function()
  local keys_to_check = {
    "GEMINI_API_KEY",
    "OPENAI_API_KEY",
    "ANTHROPIC_API_KEY",
    "AIHUBMIX_API_KEY",
    "GROQ_API_KEY",
    "GITHUB_TOKEN",
    "HEROKU_KEY",
  }
  
  local loaded = {}
  local missing = {}
  
  for _, key in ipairs(keys_to_check) do
    local value = vim.env[key]
    if value and value ~= "" then
      table.insert(loaded, key .. ": " .. value:sub(1, 15) .. "...")
    else
      table.insert(missing, key)
    end
  end
  
  local message = ""
  if #loaded > 0 then
    message = message .. "✅ Loaded (" .. #loaded .. "):\n" .. table.concat(loaded, "\n")
  end
  if #missing > 0 then
    if message ~= "" then message = message .. "\n\n" end
    message = message .. "❌ Missing (" .. #missing .. "):\n" .. table.concat(missing, ", ")
  end
  
  vim.notify(message, #loaded > 0 and vim.log.levels.INFO or vim.log.levels.WARN, { timeout = 5000 })
end, { noremap = true, silent = true, desc = "Check all API keys" })

-- Reload Avante (to pick up new API keys)
vim.keymap.set('n', '<leader>ar', function()
  vim.notify("🔄 Reloading Avante...", vim.log.levels.INFO)
  
  -- Close any open Avante windows
  vim.cmd('silent! AvanteToggle')
  
  -- Clear all Avante modules from cache
  for key, _ in pairs(package.loaded) do
    if key:match("^avante") then
      package.loaded[key] = nil
    end
  end
  
  -- Reload Avante through lazy.nvim
  vim.defer_fn(function()
    local lazy_ok, lazy = pcall(require, "lazy")
    if lazy_ok then
      lazy.reload({ plugins = { "avante.nvim" } })
      vim.notify("✅ Avante reloaded! New API key active.", vim.log.levels.INFO, { timeout = 2000 })
    else
      -- Fallback: just reload the module
      local avante_config = require("plugins.avante")
      if avante_config and type(avante_config) == "table" and avante_config.config then
        avante_config.config()
      end
      vim.notify("✅ Avante reloaded!", vim.log.levels.INFO)
    end
  end, 100)
end, { noremap = true, silent = true, desc = "Reload Avante" })

-- Close any floating window (useful for diagnostic popups that stay open)
vim.keymap.set('n', '<leader>dc', function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= "" then  -- It's a floating window
      vim.api.nvim_win_close(win, true)
      return
    end
  end
  vim.notify("No floating window to close", vim.log.levels.INFO)
end, { noremap = true, silent = true, desc = "Close floating window" })

-- Fix line numbers (if they're not showing)
vim.keymap.set('n', '<leader>uN', function()
  vim.wo.number = true
  vim.wo.relativenumber = false
  vim.wo.cursorline = true
  vim.wo.cursorlineopt = "number"
  vim.opt.numberwidth = 4
  
  vim.api.nvim_set_hl(0, 'LineNr', { fg = '#1a1a1a' })
  vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#50fa7b', bold = true })
  
  vim.notify("✅ Line numbers fixed! Current line in bright green.", vim.log.levels.INFO)
end, { noremap = true, silent = true, desc = "Fix line numbers" })

-- Force green cursor color (if it's showing blue)
vim.keymap.set('n', '<leader>uc', function()
  -- Set all cursor highlights to green
  vim.api.nvim_set_hl(0, 'Cursor', { fg = '#000000', bg = '#50fa7b', bold = true })
  vim.api.nvim_set_hl(0, 'lCursor', { fg = '#000000', bg = '#50fa7b', bold = true })
  vim.api.nvim_set_hl(0, 'TermCursor', { fg = '#000000', bg = '#50fa7b', bold = true })
  vim.api.nvim_set_hl(0, 'TermCursorNC', { fg = '#000000', bg = '#50fa7b' })
  
  -- Try to force terminal cursor color
  vim.fn.system([[printf '\e]12;#50fa7b\a']])
  
  vim.notify("🟢 Forcing green cursor! If still blue, your terminal overrides it.", vim.log.levels.WARN, { timeout = 3000 })
end, { noremap = true, silent = true, desc = "Force green cursor" })

-- Open Alpha dashboard (home screen) - opens in new tab with nvim-tree
vim.keymap.set('n', '<leader>;', function()
  -- Open in a new tab
  vim.cmd('tabnew')
  -- Open nvim-tree first
  vim.defer_fn(function()
    vim.cmd('NvimTreeOpen')
    -- Wait a bit for nvim-tree to open, then open Alpha in the main window
    vim.defer_fn(function()
      vim.cmd('wincmd l')  -- Move to right window (main content area)
      vim.cmd('Alpha')
    end, 50)
  end, 10)
end, { noremap = true, silent = true, desc = "Open Alpha dashboard (new tab)" })


-- Keybinding for Telescope live_grep to Ctrl+f
-- Helper function to get visual selection
function _G.get_visual_selection()
  local s_start = vim.fn.getpos("'<")
  local s_end = vim.fn.getpos("'>")
  local n_lines = math.abs(s_end[2] - s_start[2]) + 1
  local lines = vim.fn.getline(s_start[2], s_end[2])
  lines[1] = string.sub(lines[1], s_start[3])
  if n_lines == 1 then
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
  else
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
  end
  return table.concat(lines, '\n')
end

vim.api.nvim_set_keymap('v', '<C-f>',
  [[<cmd>lua require('telescope.builtin').live_grep({ default_text = get_visual_selection() })<CR>]],
  { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-f>', '<cmd>Telescope live_grep<cr>', { noremap = true, silent = true })

-- Indenting
vim.keymap.set("v", "<", "<gv", { silent = true, noremap = true })
vim.keymap.set("v", ">", ">gv", { silent = true, noremap = true })
