local on_attach = require("util.lsp").on_attach
local diagnostic_signs = require("util.icons").diagnostic_signs
local typescript_organise_imports = require("util.lsp").typescript_organise_imports

local config = function()
	require("neoconf").setup({})
	local cmp_nvim_lsp = require("cmp_nvim_lsp")
	
	-- Suppress deprecation warning for now (lspconfig v3 not released yet)
	local original_notify = vim.notify
	vim.notify = function(msg, level, opts)
		if msg and type(msg) == "string" and msg:match("lspconfig.*deprecated") then
			return  -- Suppress lspconfig deprecation warnings
		end
		-- Use original notify or print if notify plugin not loaded
		if original_notify then
			original_notify(msg, level, opts)
		else
			print(msg)
		end
	end
	
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

	-- Helper function to safely setup LSP servers
	local function setup_server(server_name, server_config)
		-- Triple-safe approach: check multiple ways
		local success = pcall(function()
			-- First check if the server config exists in lspconfig
			local configs = require("lspconfig.configs")
			if not configs[server_name] then
				-- Server not available, skip silently
				return
			end
			
			-- Server exists, try to set it up
			local server = lspconfig[server_name]
			if server and type(server.setup) == "function" then
				server.setup(server_config)
			end
		end)
		
		-- If that failed, don't try anything else - just skip this server
		if not success then
			return
		end
	end

	-- lua
	setup_server("lua_ls", {
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
	setup_server("jsonls", {
		capabilities = capabilities,
		on_attach = on_attach,
		filetypes = { "json", "jsonc" },
	})

	-- python
	setup_server("jedi_language_server", {
		capabilities = capabilities,
		on_attach = on_attach,
		filetypes = { "python" },
	})

	-- php
	setup_server("intelephense", {
		capabilities = capabilities,
		on_attach = on_attach,
		filetypes = { "php" },
	})

	-- typescript
	setup_server("ts_ls", {
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
	setup_server("bashls", {
		capabilities = capabilities,
		on_attach = on_attach,
		filetypes = { "sh", "aliasrc" },
	})

	-- docker
	setup_server("dockerls", {
		capabilities = capabilities,
		on_attach = on_attach,
	})

	-- C/C++
	setup_server("clangd", {
		capabilities = capabilities,
		on_attach = on_attach,
		cmd = {
			"clangd",
			"--offset-encoding=utf-16",
		},
	})

	-- gopls
	setup_server("gopls", {
		capabilities = capabilities,
		on_attach = on_attach,
		cmd = { "gopls" },
		filetypes = { "go", "gomod", "gowork", "gotmpl" },
		root_dir = lspconfig.util.root_pattern("go.work", "go.mod", ".git"),
		settings = {
			gopls = {
				usePlaceholders = true,
				completeUnimported = true,
				staticcheck = false,
				analyses = {
					unusedparams = true,
					shadow = true,
					nilness = true,
					unusedwrite = true,
					undeclaredname = true,
				},
				gofumpt = true,
			},
		},
	})

	-- efm setup (only if efm-langserver is installed)
	if vim.fn.executable("efm-langserver") == 1 then
		local ok_efmls, _ = pcall(require, "efmls-configs.linters.luacheck")
		if ok_efmls then
			pcall(function()
				local luacheck = require("efmls-configs.linters.luacheck")
				local flake8 = require("efmls-configs.linters.flake8")
				local eslint = require("efmls-configs.linters.eslint")
				local hadolint = require("efmls-configs.linters.hadolint")
				local phpcs = require("efmls-configs.linters.phpcs")
				local golangci_lint = require("efmls-configs.linters.golangci_lint")

				setup_server("efm", {
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
						"go",
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
							go = { golangci_lint },
							php = {
								{ phpcs },
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
			end)
		end
	end

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
