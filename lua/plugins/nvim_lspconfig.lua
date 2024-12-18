local on_attach = require("util.lsp").on_attach
local diagnostic_signs = require("util.icons").diagnostic_signs
local typescript_organise_imports = require("util.lsp").typescript_organise_imports
local config = function()
	require("neoconf").setup({})
	local cmp_nvim_lsp = require("cmp_nvim_lsp")
	local lspconfig = require("lspconfig")
	local capabilities = cmp_nvim_lsp.default_capabilities()

	------- Configure diagnostics --------
	vim.diagnostic.config({
		virtual_text = false,
		underline = true,
		update_in_insert = false,
		severity_sort = true,

		float = {
			border = 'rounded',
			source = 'always',
			header = '',
			prefix = '',
		},
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = diagnostic_signs.Error,
				[vim.diagnostic.severity.WARN] = diagnostic_signs.Warn,
				[vim.diagnostic.severity.INFO] = diagnostic_signs.Info,
				[vim.diagnostic.severity.HINT] = diagnostic_signs.Hint,
			}
		},
	})

	-- lua
	lspconfig.lua_ls.setup({
		capabilities = capabilities,
		on_attach = on_attach,
		settings = {
			Lua = {
				diagnostics = {
					globals = { "vim" },
				},
				workspace = {
					library = {
						vim.fn.expand("$VIMRUNTIME/lua"),
						vim.fn.expand("$XDG_CONFIG_HOME") .. "/nvim/lua",
					},
				},
			},
		},
	})

	-- json
	lspconfig.jsonls.setup({
		capabilities = capabilities,
		on_attach = on_attach,
		filetypes = { "json", "jsonc" },
	})

	-- python
	lspconfig.jedi_language_server.setup({
		capabilities = capabilities,
		on_attach = on_attach,
		filetypes = { "python" },
	})

	-- php
	lspconfig.intelephense.setup({
		capabilities = capabilities,
		on_attach = on_attach,
		filetypes = { "php" },
	})

	-- typescript
	lspconfig.ts_ls.setup({
		on_attach = on_attach,
		capabilities = capabilities,
		filetypes = {
			"typescript",
			"javascript",
			"typescriptreact",
			"javascriptreact",
		},
		commands = {
			TypeScriptOrganizeImports = typescript_organise_imports,
		},
		settings = {
			typescript = {
				indentStyle = "space",
				indentSize = 2,
			},
		},
		root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", ".git"),
	})

	-- bash
	lspconfig.bashls.setup({
		capabilities = capabilities,
		on_attach = on_attach,
		filetypes = { "sh", "aliasrc" },
	})

	-- docker
	lspconfig.dockerls.setup({
		capabilities = capabilities,
		on_attach = on_attach,
	})

	-- C/C++
	lspconfig.clangd.setup({
		capabilities = capabilities,
		on_attach = on_attach,
		cmd = {
			"clangd",
			"--offset-encoding=utf-16",
		},
	})

	local luacheck = require("efmls-configs.linters.luacheck")
	local flake8 = require("efmls-configs.linters.flake8")
	local eslint = require("efmls-configs.linters.eslint")
	local hadolint = require("efmls-configs.linters.hadolint")
	local phpcs = require("efmls-configs.linters.phpcs")

	-- configure efm server
	lspconfig.efm.setup({
		filetypes = {
			"lua",
			"python",
			"php",
			"javascript",
			"typescript",
			"markdown",
			"docker",
			"html",
			"css",
			"c",
			"cpp",
		},
		init_options = {
			documentFormatting = true,
			documentRangeFormatting = true,
			hover = true,
			documentSymbol = true,
			codeAction = true,
			completion = true,
		},
		settings = {
			languages = {
				lua = { luacheck },
				python = { flake8 },
				typescript = { eslint },
				javascript = { eslint },
				markdown = { eslint },
				docker = { hadolint },
				html = { eslint },
				css = { eslint },
				php = {
					{
						formatCommand = "phpcs --standard=~/code-rules/phpcs.xml --report=checkstyle",
						formatStdin = true,
					},
					{
						lintCommand = "phpcs --standard=~/code-rules/phpcs.xml --report=checkstyle -",
						lintStdin = true,
						lintFormats = {
							"%f:%l %m",
						},
					},
				},
			},
		},
	})

	-- Format on InsertLeave (when exiting insert mode)
	-- -- Create a group for LSP formatting
	-- local lsp_fmt_group = vim.api.nvim_create_augroup("LspFormattingGroup", {})
	--
	-- -- Create an autocommand to format on InsertLeave
	-- vim.api.nvim_create_autocmd("InsertLeave", {
	-- 	group = lsp_fmt_group,
	-- 	pattern = "*",                                    -- Apply to all buffers
	-- 	callback = function()
	-- 		local clients = vim.lsp.get_clients({ bufnr = 0 }) -- Get clients attached to the current buffer
	-- 		if #clients > 0 then
	-- 			vim.lsp.buf.format({ async = true })
	-- 		end
	-- 	end,
	-- })


	vim.api.nvim_set_keymap('n', '<leader>do', '<cmd>lua vim.diagnostic.open_float()<CR>',
		{ noremap = true, silent = true })
	vim.api.nvim_set_keymap('n', '<leader>d[', '<cmd>lua vim.diagnostic.goto_prev()<CR>', { noremap = true, silent = true })
	vim.api.nvim_set_keymap('n', '<leader>d]', '<cmd>lua vim.diagnostic.goto_next()<CR>', { noremap = true, silent = true })
end

return {
	"neovim/nvim-lspconfig",
	config = config,
	lazy = false,
	dependencies = {
		"windwp/nvim-autopairs",
		"williamboman/mason.nvim",
		"creativenull/efmls-configs-nvim",
		"hrsh7th/nvim-cmp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-nvim-lsp",
	},
}
