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
	
	-- Calculate centered position in the CURRENT window (not full editor).
	local cur_win_width = vim.api.nvim_win_get_width(0)
	local cur_win_height = vim.api.nvim_win_get_height(0)
	local width = math.min(70, math.max(40, math.floor(cur_win_width * 0.9)))
	local height = math.min(#lines + 2, math.max(6, math.floor(cur_win_height * 0.8)))
	local row = math.max(0, math.floor((cur_win_height - height) / 2))
	local col = math.max(0, math.floor((cur_win_width - width) / 2))
	
	-- Create floating window
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "win",
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
	
	-- Calculate centered position in the CURRENT window (not full editor).
	local cur_win_width = vim.api.nvim_win_get_width(0)
	local cur_win_height = vim.api.nvim_win_get_height(0)
	local width = math.min(70, math.max(40, math.floor(cur_win_width * 0.9)))
	local height = math.min(#lines + 2, math.max(6, math.floor(cur_win_height * 0.8)))
	local row = math.max(0, math.floor((cur_win_height - height) / 2))
	local col = math.max(0, math.floor((cur_win_width - width) / 2))
	
	-- Create floating window
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "win",
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

-- Diagnostic toggles with persistence for global state.
local diagnostics_state_file = vim.fn.stdpath("state") .. "/diagnostics_state.json"
local diagnostics_config_backup = nil

local function diagnostics_sync_nvim_tree(enabled)
  local ok_diag, tree_diag = pcall(require, "nvim-tree.diagnostics")
  if ok_diag and tree_diag then
    tree_diag.enable = enabled
  end

  local ok_core, core = pcall(require, "nvim-tree.core")
  if ok_core and core and core.get_explorer then
    local explorer = core.get_explorer()
    if explorer and explorer.renderer and explorer.renderer.draw then
      pcall(explorer.renderer.draw, explorer.renderer)
      return
    end
  end

  local ok_api, api = pcall(require, "nvim-tree.api")
  if ok_api and api and api.tree and api.tree.is_visible and api.tree.reload then
    if api.tree.is_visible() then
      pcall(api.tree.reload)
    end
  end
end

local function diagnostics_apply_display_config(enabled)
  if enabled then
    if diagnostics_config_backup then
      vim.diagnostic.config(diagnostics_config_backup)
    end
    return
  end

  if not diagnostics_config_backup then
    diagnostics_config_backup = vim.deepcopy(vim.diagnostic.config())
  end

  vim.diagnostic.config({
    virtual_text = false,
    signs = false,
    underline = false,
    update_in_insert = false,
    float = false,
  })
end

local function diagnostics_read_state()
  local file = io.open(diagnostics_state_file, "r")
  if not file then
    return nil
  end
  local content = file:read("*a")
  file:close()
  if not content or content == "" then
    return nil
  end

  local ok, decoded = pcall(vim.json.decode, content)
  if ok and type(decoded) == "table" then
    return decoded
  end
  return nil
end

local function diagnostics_write_state(global_enabled)
  local dir = vim.fn.fnamemodify(diagnostics_state_file, ":h")
  vim.fn.mkdir(dir, "p")
  local file = io.open(diagnostics_state_file, "w")
  if not file then
    return
  end
  file:write(vim.json.encode({ global_enabled = global_enabled }))
  file:close()
end

local function diagnostics_set_enabled(bufnr, enabled)
  -- Neovim changed diagnostic APIs across versions:
  -- newer:  vim.diagnostic.enable(boolean, { bufnr = n })
  -- older:  vim.diagnostic.enable(bufnr) / vim.diagnostic.disable(bufnr)
  local api_ok = false
  if type(vim.diagnostic.enable) == "function" then
    if bufnr ~= nil then
      api_ok = pcall(vim.diagnostic.enable, enabled, { bufnr = bufnr })
      if not api_ok and enabled then
        api_ok = pcall(vim.diagnostic.enable, bufnr)
      end
      if not api_ok and (not enabled) and type(vim.diagnostic.disable) == "function" then
        api_ok = pcall(vim.diagnostic.disable, bufnr)
      end
    else
      api_ok = pcall(vim.diagnostic.enable, enabled)
      if not api_ok and enabled then
        api_ok = pcall(vim.diagnostic.enable)
      end
      if not api_ok and (not enabled) and type(vim.diagnostic.disable) == "function" then
        api_ok = pcall(vim.diagnostic.disable)
      end
    end
  end
  if api_ok then
    return
  end

  if bufnr ~= nil then
    if enabled then
      vim.diagnostic.show(nil, bufnr)
    else
      vim.diagnostic.hide(nil, bufnr)
    end
    return
  end

  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if enabled then
      vim.diagnostic.show(nil, b)
    else
      vim.diagnostic.hide(nil, b)
    end
  end
end

local function diagnostics_buffer_allowed(bufnr)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  if vim.b[bufnr].diagnostics_enabled == false then
    return false
  end

  local ft = vim.bo[bufnr].filetype
  if (vim.g.clojure_diagnostics_enabled == false) and (ft == "clojure" or ft == "edn") then
    return false
  end

  return true
end

local function diagnostics_apply_global_state(enabled, persist)
  vim.g.diagnostics_global_enabled = enabled
  diagnostics_apply_display_config(enabled)
  diagnostics_sync_nvim_tree(enabled)

  diagnostics_set_enabled(nil, enabled)
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) then
      if enabled and diagnostics_buffer_allowed(b) then
        vim.diagnostic.show(nil, b)
      else
        vim.diagnostic.hide(nil, b)
      end
    end
  end

  if persist then
    diagnostics_write_state(enabled)
  end
end

-- Initialize persisted global diagnostics state (default ON).
do
  local state = diagnostics_read_state()
  local enabled = true
  if state and state.global_enabled == false then
    enabled = false
  end
  diagnostics_apply_global_state(enabled, false)
end

-- Keep buffers in sync with global and clojure-specific toggles.
vim.api.nvim_create_autocmd({ "BufEnter", "LspAttach", "FileType" }, {
  group = vim.api.nvim_create_augroup("DiagnosticsToggleSync", { clear = true }),
  pattern = "*",
  callback = function(args)
    local bufnr = args.buf
    if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end

    if vim.g.diagnostics_global_enabled == false then
      diagnostics_apply_display_config(false)
      vim.diagnostic.hide(nil, bufnr)
      return
    end

    if vim.b[bufnr].diagnostics_enabled == false then
      vim.diagnostic.hide(nil, bufnr)
      return
    end

    local ft = vim.bo[bufnr].filetype
    local clojure_off = (vim.g.clojure_diagnostics_enabled == false) and (ft == "clojure" or ft == "edn")
    if clojure_off then
      vim.diagnostic.hide(nil, bufnr)
      return
    end

    diagnostics_set_enabled(bufnr, true)
  end,
})

-- Toggle diagnostics for the current buffer (works for any filetype/source).
vim.keymap.set('n', '<leader>dt', function()
  local bufnr = vim.api.nvim_get_current_buf()
  local ok, enabled = pcall(vim.diagnostic.is_enabled, { bufnr = bufnr })
  if not ok then
    ok, enabled = pcall(vim.diagnostic.is_enabled, bufnr)
  end
  if not ok then
    enabled = vim.b[bufnr].diagnostics_enabled ~= false
  end

  diagnostics_set_enabled(bufnr, not enabled)
  vim.b[bufnr].diagnostics_enabled = not enabled
  vim.notify(
    (enabled and "Diagnostics OFF (current buffer)" or "Diagnostics ON (current buffer)"),
    vim.log.levels.INFO
  )
  diagnostics_sync_nvim_tree(vim.g.diagnostics_global_enabled ~= false)
end, { noremap = true, silent = true, desc = "Toggle diagnostics (buffer)" })

-- Toggle diagnostics globally (all buffers / all sources), persisted across restarts.
vim.keymap.set('n', '<leader>dT', function()
  local enabled = vim.g.diagnostics_global_enabled ~= false
  diagnostics_apply_global_state(not enabled, true)
  vim.notify(
    (enabled and "Diagnostics OFF (global)" or "Diagnostics ON (global)"),
    vim.log.levels.INFO
  )
end, { noremap = true, silent = true, desc = "Toggle diagnostics (global)" })

-- Toggle diagnostics only for Clojure / EDN buffers (useful when clj-kondo noise is too high).
vim.keymap.set('n', '<leader>dk', function()
  local enabled = vim.g.clojure_diagnostics_enabled ~= false
  vim.g.clojure_diagnostics_enabled = not enabled

  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) then
      local ft = vim.bo[b].filetype
      if ft == "clojure" or ft == "edn" then
        local allow = (vim.g.diagnostics_global_enabled ~= false) and (vim.g.clojure_diagnostics_enabled ~= false)
        diagnostics_set_enabled(b, allow)
      end
    end
  end

  vim.notify(
    enabled and "Clojure diagnostics OFF" or "Clojure diagnostics ON",
    vim.log.levels.INFO
  )
  diagnostics_sync_nvim_tree(vim.g.diagnostics_global_enabled ~= false)
end, { noremap = true, silent = true, desc = "Toggle diagnostics (Clojure)" })

-- Clear Clojure analysis caches and restart clojure-lsp for the current workspace.
vim.api.nvim_create_user_command("ClojureCacheReset", function()
  local paths = {
    vim.fn.stdpath("cache") .. "/clojure-lsp",
    vim.fn.stdpath("cache") .. "/clj-kondo",
    vim.fn.getcwd() .. "/.lsp/.cache",
    vim.fn.getcwd() .. "/.clj-kondo/.cache",
  }

  for _, p in ipairs(paths) do
    if vim.fn.isdirectory(p) == 1 then
      vim.fn.delete(p, "rf")
    end
    vim.fn.mkdir(p, "p")
  end

  for _, client in ipairs(vim.lsp.get_clients({ name = "clojure_lsp" })) do
    client.stop(true)
  end

  vim.defer_fn(function()
    vim.cmd("edit")
    vim.notify("Clojure caches cleared and clojure-lsp restarted", vim.log.levels.INFO)
  end, 200)
end, { desc = "Clear Clojure caches and restart clojure-lsp" })

vim.keymap.set('n', '<leader>dK', '<cmd>ClojureCacheReset<CR>', {
  noremap = true,
  silent = true,
  desc = "Reset Clojure caches",
})

-- GLOBAL code action keybinding (works everywhere, not just LSP buffers)
vim.keymap.set('n', '<leader>ca', '<cmd>Lspsaga code_action<CR>', 
	{ noremap = true, silent = true, desc = "Code actions" })

local function run_ex_command_or_notify(cmd, desc)
  local name = cmd:match("^%s*([%w_#%.%-]+)")
  if not name or vim.fn.exists(":" .. name) == 0 then
    vim.notify((desc or cmd) .. " command is unavailable", vim.log.levels.WARN)
    return
  end
  vim.cmd(cmd)
end

-- map explorer command to make it easier to open
vim.keymap.set("n", "<leader>pv", function()
  if vim.fn.exists(":Ex") > 0 then
    vim.cmd("Ex")
  else
    run_ex_command_or_notify("NvimTreeToggle", "Explorer")
  end
end, { desc = "Explorer view" })

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
-- NOTE: `qq/ww/wq` are two-key normal-mode maps on top of builtin `q`/`w`.
-- They can feel laggy due to timeout-based key sequence resolution.
-- Keep them for compatibility, but make handlers minimal and add instant aliases.
vim.keymap.set('n', 'qq', '<cmd>q!<CR>', {
  silent = true,
  nowait = true,
  desc = "Quit current window",
})
vim.keymap.set('n', 'wq', '<cmd>wq!<CR>', {
  silent = true,
  nowait = true,
  desc = "Write and quit",
})
vim.keymap.set('n', 'ww', '<cmd>w<CR>', {
  silent = true,
  nowait = true,
  desc = "Write file",
})

-- Instant, non-sequence aliases (no timeout wait).
vim.keymap.set('n', 'Q', '<cmd>q!<CR>', { silent = true, desc = "Quit current window (instant)" })
vim.keymap.set('n', 'W', '<cmd>w<CR>', { silent = true, desc = "Write file (instant)" })
vim.keymap.set('n', 'WQ', '<cmd>wq!<CR>', { silent = true, desc = "Write and force quit (instant)" })


-- -- Code_Runner
vim.keymap.set('n', '<leader>r', function()
  run_ex_command_or_notify("RunCode", "RunCode")
end, { noremap = true, silent = true, desc = "Run code" })
vim.keymap.set('n', '<leader>rf', function()
  run_ex_command_or_notify("RunFile", "RunFile")
end, { noremap = true, silent = true, desc = "Run file" })
vim.keymap.set('n', '<leader>rft', function()
  run_ex_command_or_notify("RunFile tab", "RunFile tab")
end, { noremap = true, silent = true, desc = "Run file in tab" })
vim.keymap.set('n', '<leader>rp', function()
  run_ex_command_or_notify("RunProject", "RunProject")
end, { noremap = true, silent = true, desc = "Run project" })
vim.keymap.set('n', '<leader>rc', function()
  run_ex_command_or_notify("RunClose", "RunClose")
end, { noremap = true, silent = true, desc = "Run close" })
vim.keymap.set('n', '<leader>crf', function()
  run_ex_command_or_notify("CRFiletype", "CRFiletype")
end, { noremap = true, silent = true, desc = "Code runner filetype" })
vim.keymap.set('n', '<leader>crp', function()
  run_ex_command_or_notify("CRProjects", "CRProjects")
end, { noremap = true, silent = true, desc = "Code runner projects" })

-- ⚡ RELOAD EVERYTHING - Config + Environment Variables
local function restore_ui_state_after_reload()
  if type(_G.apply_nvim_tree_highlights) == "function" then
    pcall(_G.apply_nvim_tree_highlights)
  else
    pcall(vim.cmd, "highlight NvimTreeNormal guibg=NONE ctermbg=NONE")
    pcall(vim.cmd, "highlight NvimTreeNormalNC guibg=NONE ctermbg=NONE")
    pcall(vim.cmd, "highlight WinSeparator guifg=#8B8B8B guibg=NONE")
  end
  pcall(vim.cmd, "redraw!")
end

local function reload_loaded_plugins_silent()
  local ok_plugin, plugin = pcall(require, "lazy.core.plugin")
  if ok_plugin and type(plugin.load) == "function" then
    pcall(plugin.load)
  end
end

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
  
  -- 2. Clear loaded Lua modules (do NOT re-source init.lua; lazy.nvim doesn't support that)
  for name, _ in pairs(package.loaded) do
    if name:match('^config') or name:match('^plugins') or name:match('^util') then
      package.loaded[name] = nil
    end
  end

  if vim.loader and type(vim.loader.reset) == "function" then
    pcall(vim.loader.reset)
  end
  
  -- 3. Reload core config modules
  pcall(require, "config")

  -- 4. Reload already-loaded plugins without lazy's noisy command wrapper.
  reload_loaded_plugins_silent()

  vim.defer_fn(restore_ui_state_after_reload, 120)
  
  vim.notify("✨ Everything reloaded!", vim.log.levels.INFO, { timeout = 1500 })
end

-- Simple config-only reload (no env vars)
_G.reload_config = function()
  for name, _ in pairs(package.loaded) do
    if name:match('^config') or name:match('^plugins') or name:match('^util') then
      package.loaded[name] = nil
    end
  end
  if vim.loader and type(vim.loader.reset) == "function" then
    pcall(vim.loader.reset)
  end

  pcall(require, "config")

  reload_loaded_plugins_silent()

  vim.defer_fn(restore_ui_state_after_reload, 120)

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

vim.keymap.set('v', '<C-f>', function()
  local theme = require("telescope.themes").get_cursor({
    layout_config = { width = 0.92, height = 0.75 },
  })
  require('telescope.builtin').live_grep(vim.tbl_extend("force", theme, {
    default_text = _G.get_visual_selection(),
  }))
end, { noremap = true, silent = true, desc = "Live grep (visual selection)" })

vim.keymap.set('n', '<C-f>', function()
  local theme = require("telescope.themes").get_cursor({
    layout_config = { width = 0.92, height = 0.75 },
  })
  require('telescope.builtin').live_grep(theme)
end, { noremap = true, silent = true, desc = "Live grep" })

-- Indenting
vim.keymap.set("v", "<", "<gv", { silent = true, noremap = true })
vim.keymap.set("v", ">", ">gv", { silent = true, noremap = true })
