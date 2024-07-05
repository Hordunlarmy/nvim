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
	mapkey("<leader>D", "Lspsaga show_line_diagnostics", "n", opts)    -- show  diagnostics for line
	mapkey("<leader>d", "Lspsaga show_cursor_diagnostics", "n", opts)  -- show diagnostics for cursor
	mapkey("<leader>pd", "Lspsaga diagnostic_jump_prev", "n", opts)    -- jump to prev diagnostic in buffer
	mapkey("<leader>nd", "Lspsaga diagnostic_jump_next", "n", opts)    -- jump to next diagnostic in buffer
	mapkey("K", "Lspsaga hover_doc", "n", opts)                        -- show documentation for what is under cursor
	mapkey("<A-d>", "Lspsaga term_toggle", "n", opts)                  -- terminal buffer


	if client.name == "tsserver" then
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
