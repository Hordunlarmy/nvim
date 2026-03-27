local on_attach = require("util.lsp").on_attach
local diagnostic_signs = require("util.icons").diagnostic_signs
local typescript_organise_imports = require("util.lsp").typescript_organise_imports

local config = function()
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

	local function setup_server(server_name, server_config)
		local ok, server = pcall(function() return lspconfig[server_name] end)
		if ok and server and type(server.setup) == "function" then
			server.setup(server_config)
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

	-- clojure
	local clojure_root = lspconfig.util.root_pattern("project.clj", "deps.edn", "build.boot", "shadow-cljs.edn", "bb.edn")
	local clojure_lsp_cache = vim.fn.stdpath("cache") .. "/clojure-lsp"
	local clj_kondo_cache = vim.fn.stdpath("cache") .. "/clj-kondo"
	vim.fn.mkdir(clojure_lsp_cache, "p")
	vim.fn.mkdir(clj_kondo_cache, "p")
	setup_server("clojure_lsp", {
		capabilities = capabilities,
		on_attach = on_attach,
		filetypes = { "clojure", "edn" },
		cmd_env = {
			CLJ_KONDO_CACHE = clj_kondo_cache,
		},
		init_options = {
			["cache-path"] = clojure_lsp_cache,
			["lint-project-files-after-startup?"] = false,
			["paths-ignore-regex"] = {
				".*/target/.*",
				".*/node_modules/.*",
				".*/.shadow-cljs/.*",
			},
		},
		root_dir = function(fname)
			return clojure_root(fname)
		end,
		single_file_support = false,
		-- Let clojure-lsp discover classpath from project tooling; custom init_options
		-- here can cause classpath lookup failures in Lein profile-based projects.
	})

	-- efm setup (only if efm-langserver is installed)
	-- Conditionally loads linters based on what's actually installed
	if vim.fn.executable("efm-langserver") == 1 then
		pcall(function()
			-- Only load linters that have their executable installed
			local languages = {}
			local filetypes = {}
			
			-- Lua (luacheck)
			if vim.fn.executable("luacheck") == 1 then
				local luacheck = require("efmls-configs.linters.luacheck")
				languages.lua = { luacheck }
				table.insert(filetypes, "lua")
			end
			
			-- Python (flake8)
			if vim.fn.executable("flake8") == 1 then
				local flake8 = require("efmls-configs.linters.flake8")
				languages.python = { flake8 }
				table.insert(filetypes, "python")
			end
			
			-- JavaScript/TypeScript (eslint) - already installed
			if vim.fn.executable("eslint") == 1 then
				local eslint = require("efmls-configs.linters.eslint")
				languages.javascript = { eslint }
				languages.typescript = { eslint }
				languages.markdown = { eslint }
				languages.html = { eslint }
				languages.css = { eslint }
				vim.list_extend(filetypes, { "javascript", "typescript", "markdown", "html", "css" })
			end
			
			-- Docker (hadolint)
			if vim.fn.executable("hadolint") == 1 then
				local hadolint = require("efmls-configs.linters.hadolint")
				languages.docker = { hadolint }
				table.insert(filetypes, "docker")
			end
			
			-- PHP (phpcs)
			if vim.fn.executable("phpcs") == 1 then
				local phpcs = require("efmls-configs.linters.phpcs")
				languages.php = {
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
				}
				table.insert(filetypes, "php")
			end
			
			-- Clojure (clj-kondo)
			-- Avoid duplicate Clojure diagnostics when clojure-lsp is active.
			if vim.fn.executable("clj-kondo") == 1 and vim.fn.executable("clojure-lsp") ~= 1 then
				languages.clojure = {
					{
						lintCommand = "clj-kondo --lint -",
						lintStdin = true,
						lintFormats = { "%f:%l:%c: %trror: %m", "%f:%l:%c: %tarning: %m" },
					},
				}
				table.insert(filetypes, "clojure")
			end
			
			-- Go (golangci-lint)
			if vim.fn.executable("golangci-lint") == 1 then
				local golangci_lint = require("efmls-configs.linters.golangci_lint")
				languages.go = { golangci_lint }
				table.insert(filetypes, "go")
			end
			
			-- Only setup efm if we have at least one linter
			if #filetypes > 0 then
				setup_server("efm", {
					filetypes = filetypes,
					init_options = {
						documentFormatting = true,
						documentRangeFormatting = true,
						hover = true,
						documentSymbol = true,
						codeAction = true,
						completion = true,
					},
					settings = {
						languages = languages,
					},
				})
			end
		end)
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


	vim.keymap.set('n', '<leader>d[', vim.diagnostic.goto_prev, { silent = true, desc = "Prev diagnostic" })
	vim.keymap.set('n', '<leader>d]', vim.diagnostic.goto_next, { silent = true, desc = "Next diagnostic" })
end

return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	config = config,
	dependencies = {
		"windwp/nvim-autopairs",
		"williamboman/mason.nvim",
		"creativenull/efmls-configs-nvim",
		"hrsh7th/nvim-cmp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-nvim-lsp",
	},
}
