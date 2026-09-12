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
	local definition_highlight_ns = vim.api.nvim_create_namespace("LspDefinitionJumpHighlight")

	local function first_location(result)
		if vim.islist(result) then
			return result[1]
		end
		return result
	end

	local function count_character(line, character)
		return select(2, line:gsub(vim.pesc(character), ""))
	end

	local function definition_bounds(lines, target_line, filetype)
		local start_line = target_line
		local opening, closing, declaration_pattern

		if filetype == "clojure" or filetype == "clojurescript" or filetype == "clojurec" then
			declaration_pattern = "^%s*%(%s*def[%w%-%?!%*]*"
			opening, closing = "(", ")"
		elseif filetype == "go" then
			declaration_pattern = "^%s*func%s+"
			opening, closing = "{", "}"
		elseif filetype == "rust" then
			declaration_pattern = "^%s*pub%s+.*fn%s+"
			opening, closing = "{", "}"
		elseif filetype == "python" then
			declaration_pattern = "^%s*def%s+"
		elseif filetype == "javascript" or filetype == "typescript" or filetype == "javascriptreact" or filetype == "typescriptreact" then
			declaration_pattern = "^%s*.*function%s+"
			opening, closing = "{", "}"
		elseif filetype == "php" then
			declaration_pattern = "^%s*.*function%s+"
			opening, closing = "{", "}"
		elseif filetype == "java" then
			opening, closing = "{", "}"
		end

		if declaration_pattern then
			for line_no = target_line, math.max(1, target_line - 100), -1 do
				if lines[line_no]:match(declaration_pattern) then
					start_line = line_no
					break
				end
			end
		end

		if filetype == "python" then
			local indent = #(lines[start_line]:match("^(%s*)") or "")
			local end_line = start_line
			for line_no = start_line + 1, math.min(#lines, start_line + 250) do
				local line = lines[line_no]
				if line:match("%S") and #(line:match("^(%s*)") or "") <= indent then break end
				end_line = line_no
			end
			return start_line, end_line
		end

		if opening and closing then
			local depth, opened, end_line = 0, false, start_line
			for line_no = start_line, math.min(#lines, start_line + 500) do
				local line = lines[line_no]
				local opens = count_character(line, opening)
				local closes = count_character(line, closing)
				if opens > 0 then opened = true end
				depth = depth + opens - closes
				end_line = line_no
				if opened and depth <= 0 then break end
			end
			return start_line, end_line
		end

		return start_line, math.min(#lines, start_line + 40)
	end

	local function highlight_definition_target()
		local target_buf = vim.api.nvim_get_current_buf()
		local row, col = unpack(vim.api.nvim_win_get_cursor(0))
		local symbol = vim.fn.expand("<cword>")
		if symbol == "" then
			return
		end
		vim.api.nvim_buf_clear_namespace(target_buf, definition_highlight_ns, 0, -1)
		vim.api.nvim_buf_add_highlight(target_buf, definition_highlight_ns, "Search", row - 1, col, col + #symbol)
		vim.defer_fn(function()
			if vim.api.nvim_buf_is_valid(target_buf) then
				vim.api.nvim_buf_clear_namespace(target_buf, definition_highlight_ns, 0, -1)
			end
		end, 800)
	end

	local function jump_to_definition()
		local origin_buf = vim.api.nvim_get_current_buf()
		local origin_row, origin_col = unpack(vim.api.nvim_win_get_cursor(0))
		vim.lsp.buf.definition()
		vim.defer_fn(function()
			if not vim.api.nvim_buf_is_valid(origin_buf) then
				return
			end
			local current_row, current_col = unpack(vim.api.nvim_win_get_cursor(0))
			if vim.api.nvim_get_current_buf() ~= origin_buf or current_row ~= origin_row or current_col ~= origin_col then
				vim.cmd("normal! zz")
				highlight_definition_target()
			end
		end, 150)
	end

	local function request_definition(on_location)
		local position_encoding = client.offset_encoding or "utf-16"
		local params = vim.lsp.util.make_position_params(0, position_encoding)
		vim.lsp.buf_request_all(bufnr, "textDocument/definition", params, function(responses)
			for client_id, response in pairs(responses) do
				local location = response.result and first_location(response.result)
				if location then
					on_location(location, vim.lsp.get_client_by_id(client_id))
					return
				end
			end
			vim.notify("No definition found", vim.log.levels.INFO)
		end)
	end

	local function preview_definition()
		local anchor_win = vim.api.nvim_get_current_win()
		request_definition(function(location)
			local uri = location.targetUri or location.uri
			local range = location.targetRange or location.range
			if not uri or not range then
				vim.notify("Definition preview is unavailable", vim.log.levels.INFO)
				return
			end

			local source_buf = vim.uri_to_bufnr(uri)
			pcall(vim.fn.bufload, source_buf)
			local source_lines = vim.api.nvim_buf_get_lines(source_buf, 0, -1, false)
			if #source_lines == 0 then
				vim.notify("Definition source is unavailable", vim.log.levels.INFO)
				return
			end

			local target_line = math.min(range.start.line + 1, #source_lines)
			local start_line, end_line = definition_bounds(source_lines, target_line, vim.bo[source_buf].filetype)

			local lines = vim.list_slice(source_lines, start_line, end_line)
			local source_name = vim.api.nvim_buf_get_name(source_buf)
			local writable = source_name ~= "" and vim.fn.filewritable(source_name) == 1
			local source_end_line = end_line
			local preview_buf = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_buf_set_name(preview_buf, "definition-preview://" .. tostring(preview_buf))
			vim.bo[preview_buf].bufhidden = "wipe"
			vim.bo[preview_buf].buftype = writable and "acwrite" or "nofile"
			vim.bo[preview_buf].swapfile = false
			vim.bo[preview_buf].filetype = vim.bo[source_buf].filetype
			vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, lines)
			vim.bo[preview_buf].modifiable = writable

			local win = vim.api.nvim_win_is_valid(anchor_win) and anchor_win or vim.api.nvim_get_current_win()
			local win_width = vim.api.nvim_win_get_width(win)
			local win_height = vim.api.nvim_win_get_height(win)
			local width = math.min(math.max(70, math.floor(win_width * 0.86)), 160)
			local height = math.min(math.max(12, math.floor(win_height * 0.78)), math.max(6, #lines + 2))
			local preview_win = vim.api.nvim_open_win(preview_buf, true, {
				relative = "win",
				win = win,
				row = math.max(0, math.floor((win_height - height) / 2)),
				col = math.max(0, math.floor((win_width - width) / 2)),
				width = width,
				height = height,
				style = "minimal",
				border = "rounded",
				title = writable and " Definition preview — :w saves " or " Definition preview ",
				title_pos = "center",
				footer = source_name,
				footer_pos = "center",
			})
			vim.wo[preview_win].number = true
			vim.wo[preview_win].relativenumber = false
			vim.wo[preview_win].cursorline = true
			vim.api.nvim_win_set_cursor(preview_win, { math.max(1, target_line - start_line + 1), 0 })
			if writable then
				local save_group = vim.api.nvim_create_augroup("DefinitionPreviewSave" .. preview_buf, { clear = true })
				local register_save_handler
				local function save_preview()
					local updated_lines = vim.api.nvim_buf_get_lines(preview_buf, 0, -1, false)
					vim.api.nvim_buf_set_lines(source_buf, start_line - 1, source_end_line, false, updated_lines)
					source_end_line = start_line - 1 + #updated_lines
					local ok, err = pcall(vim.api.nvim_buf_call, source_buf, function()
						vim.cmd("write")
					end)
					if not ok then
						vim.notify("Could not save definition: " .. tostring(err), vim.log.levels.ERROR)
						return false
					end
					vim.bo[preview_buf].modified = false
					vim.notify("Definition saved", vim.log.levels.INFO)
					return true
				end
				register_save_handler = function()
					if not vim.api.nvim_buf_is_valid(preview_buf) then
						return
					end
					vim.api.nvim_clear_autocmds({ group = save_group, buffer = preview_buf })
					vim.api.nvim_create_autocmd("BufWriteCmd", {
						group = save_group,
						buffer = preview_buf,
						callback = function()
							save_preview()
							vim.schedule(register_save_handler)
						end,
					})
				end
				register_save_handler()
				vim.api.nvim_buf_create_user_command(preview_buf, "DefinitionSave", save_preview, {})
				vim.keymap.set("n", "<C-s>", "<cmd>DefinitionSave<CR>", { buffer = preview_buf, silent = true, desc = "Save definition" })
				vim.keymap.set("i", "<C-s>", "<Esc><cmd>DefinitionSave<CR>", { buffer = preview_buf, silent = true, desc = "Save definition" })
				vim.keymap.set("n", "<leader>w", "<cmd>DefinitionSave<CR>", { buffer = preview_buf, silent = true, desc = "Save definition" })
				vim.keymap.set("i", "<leader>w", "<Esc><cmd>DefinitionSave<CR>", { buffer = preview_buf, silent = true, desc = "Save definition" })
			end
			local function close_preview()
				if vim.api.nvim_win_is_valid(preview_win) then
					vim.api.nvim_win_close(preview_win, true)
				end
			end
			vim.keymap.set("n", "q", close_preview, { buffer = preview_buf, silent = true })
			vim.keymap.set("n", "<Esc>", close_preview, { buffer = preview_buf, silent = true })
		end)
	end

	local function hover_documentation()
		local anchor_win = vim.api.nvim_get_current_win()
		local position_encoding = client.offset_encoding or "utf-16"
		local params = vim.lsp.util.make_position_params(0, position_encoding)
		vim.lsp.buf_request(bufnr, "textDocument/hover", params, function(err, result)
			if err then
				vim.notify("Documentation lookup failed: " .. (err.message or "unknown error"), vim.log.levels.WARN)
				return
			end
			if not result or not result.contents then
				vim.notify("No documentation available", vim.log.levels.INFO)
				return
			end
			local lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
			if #lines == 0 then
				vim.notify("No documentation available", vim.log.levels.INFO)
				return
			end
			local win_width = vim.api.nvim_win_get_width(anchor_win)
			local win_height = vim.api.nvim_win_get_height(anchor_win)
			local hover_buf, hover_win = vim.lsp.util.open_floating_preview(lines, "plaintext", {
				border = "rounded",
				max_width = math.max(30, math.floor(win_width * 0.9)),
				max_height = math.max(8, math.floor(win_height * 0.8)),
			})
			-- Plaintext deliberately prevents Tree-sitter from parsing injected Clojure
			-- code blocks, which crashes with the installed parser combination.
			vim.bo[hover_buf].filetype = "text"
			pcall(vim.treesitter.stop, hover_buf)
			center_float_in_window(hover_win, anchor_win)
			vim.keymap.set("n", "<Esc>", "<cmd>bdelete<CR>", { buffer = hover_buf, silent = true, nowait = true })
			vim.api.nvim_set_current_win(hover_win)
		end)
	end

	mapkey("<leader>fd", "Lspsaga finder", "n", opts)                  -- go to definition
	vim.keymap.set("n", "<leader>gd", jump_to_definition,
		{ buffer = bufnr, silent = true, desc = "LSP go to definition" })
	vim.keymap.set("n", "<leader>gD", preview_definition,
		{ buffer = bufnr, silent = true, desc = "LSP preview definition" })
	vim.keymap.set("n", "<leader>gC", vim.lsp.buf.declaration,
		{ buffer = bufnr, silent = true, desc = "LSP go to declaration" })
	vim.keymap.set("n", "<leader>gS", function()
		vim.cmd("vsplit")
		jump_to_definition()
	end, { buffer = bufnr, silent = true, desc = "LSP definition in vertical split" })
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
		hover_documentation()
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
