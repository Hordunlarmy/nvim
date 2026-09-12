local opts = {
	ensure_installed = {
		"efm",                  -- General purpose language server for linting and formatting
		"bashls",               -- Bash scripts
		"ts_ls",                -- TypeScript and JavaScript
		"basedpyright",         -- Python analysis, imports, type checking
		"lua_ls",               -- Lua (essential for Neovim config)
		"emmet_ls",             -- HTML and CSS expansion
		"jsonls",               -- JSON
		"html",                 -- HTML
		"cssls",                -- CSS
		"yamlls",               -- YAML
		"dockerls",             -- Dockerfile
		"marksman",             -- Markdown
		"gopls",                -- Go language server (for Go support)
		"clojure_lsp",          -- Clojure language server
		"intelephense",         -- PHP language server
		"jdtls",                -- Java language server
		"rust_analyzer",        -- Rust language server
		"sqls",                 -- SQL language server
	},

	automatic_installation = true, -- Automatically install language servers
}

return {
	"williamboman/mason-lspconfig.nvim",
	opts = opts,
	event = "BufReadPre",
	dependencies = "williamboman/mason.nvim",
}
