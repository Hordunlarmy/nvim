local mapkey = require("util.keymapper").mapvimkey

local M = {}

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
		local win_width = vim.api.nvim_win_get_width(0)
		local win_height = vim.api.nvim_win_get_height(0)
		vim.lsp.buf.hover({
			border = "rounded",
			max_width = math.max(30, math.floor(win_width * 0.9)),
			max_height = math.max(8, math.floor(win_height * 0.8)),
		})
	end, { buffer = bufnr, silent = true, desc = "Hover documentation" })
	mapkey("<A-d>", "Lspsaga term_toggle", "n", opts)                  -- terminal buffer


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
