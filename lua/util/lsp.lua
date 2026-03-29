local mapkey = require("util.keymapper").mapvimkey

local M = {}

local function center_float_in_window(float_win, anchor_win)
	if not float_win or not vim.api.nvim_win_is_valid(float_win) then
		return
	end
	if not anchor_win or not vim.api.nvim_win_is_valid(anchor_win) then
		return
	end

	local cfg = vim.api.nvim_win_get_config(float_win)
	if not cfg or cfg.relative == "" then
		return
	end

	local anchor_w = vim.api.nvim_win_get_width(anchor_win)
	local anchor_h = vim.api.nvim_win_get_height(anchor_win)
	local width = tonumber(cfg.width) or math.max(30, math.floor(anchor_w * 0.9))
	local height = tonumber(cfg.height) or math.max(8, math.floor(anchor_h * 0.8))

	cfg.relative = "win"
	cfg.win = anchor_win
	cfg.row = math.max(0, math.floor((anchor_h - height) / 2))
	cfg.col = math.max(0, math.floor((anchor_w - width) / 2))
	pcall(vim.api.nvim_win_set_config, float_win, cfg)
end

local function find_hover_float(bufnr)
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_is_valid(win) then
			local ok, value = pcall(vim.api.nvim_win_get_var, win, "textDocument/hover")
			if ok and value == bufnr then
				return win
			end
		end
	end
	return nil
end

local function center_hover_later(bufnr, anchor_win, attempts)
	attempts = attempts or 8
	local hover_win = find_hover_float(bufnr)
	if hover_win then
		center_float_in_window(hover_win, anchor_win)
		return
	end
	if attempts <= 1 then
		return
	end
	vim.defer_fn(function()
		center_hover_later(bufnr, anchor_win, attempts - 1)
	end, 40)
end

M.on_attach = function(client, bufnr)
	local opts = { noremap = true, silent = true, buffer = bufnr }

	mapkey("<leader>fd", "Lspsaga finder", "n", opts)                  -- go to definition
	mapkey("<leader>gd", "Lspsaga peek_definition", "n", opts)         -- peak definition
	mapkey("<leader>gD", "Lspsaga goto_definition", "n", opts)         -- go to definition
	mapkey("<leader>gS", "vsplit | Lspsaga goto_definition", "n", opts) -- go to definition
	mapkey("<leader>ca", "Lspsaga code_action", "n", opts)             -- see available code actions
	mapkey("<leader>rn", "Lspsaga rename", "n", opts)                  -- smart rename
	
	-- Diagnostic keybindings are now global (set in nvim_lspconfig.lua)
	
	mapkey("<leader>pd", "Lspsaga diagnostic_jump_prev", "n", opts)    -- jump to prev diagnostic in buffer
	mapkey("<leader>nd", "Lspsaga diagnostic_jump_next", "n", opts)    -- jump to next diagnostic in buffer
	
	-- Quick diagnostic navigation (standard Neovim convention)
	vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { buffer = bufnr, silent = true, desc = "Next diagnostic" })
	vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { buffer = bufnr, silent = true, desc = "Previous diagnostic" })
	vim.keymap.set("n", "]e", function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end, { buffer = bufnr, silent = true, desc = "Next error" })
	vim.keymap.set("n", "[e", function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end, { buffer = bufnr, silent = true, desc = "Previous error" })
	vim.keymap.set("n", "]w", function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN }) end, { buffer = bufnr, silent = true, desc = "Next warning" })
	vim.keymap.set("n", "[w", function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN }) end, { buffer = bufnr, silent = true, desc = "Previous warning" })
	vim.keymap.set("n", "K", function()
		local anchor_win = vim.api.nvim_get_current_win()
		local current_buf = vim.api.nvim_get_current_buf()
		local win_width = vim.api.nvim_win_get_width(anchor_win)
		local win_height = vim.api.nvim_win_get_height(anchor_win)
		vim.lsp.buf.hover({
			border = "rounded",
			max_width = math.max(30, math.floor(win_width * 0.9)),
			max_height = math.max(8, math.floor(win_height * 0.8)),
		})
		center_hover_later(current_buf, anchor_win)
	end, { buffer = bufnr, silent = true, desc = "Hover documentation" })
	mapkey("<A-d>", "Lspsaga term_toggle", "n", opts)                  -- terminal buffer

	local ok_navic, navic = pcall(require, "nvim-navic")
	if ok_navic and client.server_capabilities and client.server_capabilities.documentSymbolProvider then
		pcall(navic.attach, client, bufnr)
	end

	if client.name == "ts_ls" then
		mapkey("<leader>oi", "TypeScriptOrganizeImports", "n", opts) -- organise imports
	end
end

M.typescript_organise_imports = {
	description = "Organise Imports",
	function()
		local params = {
			command = "_typescript.organizeImports",
			arguments = { vim.fn.expand("%:p") },
		}
		-- reorganise imports
		vim.lsp.buf.execute_command(params)
	end,
}

return M
