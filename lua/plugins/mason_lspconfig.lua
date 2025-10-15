local opts = {
	ensure_installed = {
		"efm",                  -- General purpose language server for linting and formatting
		"bashls",               -- Bash scripts
		"ts_ls",                -- TypeScript and JavaScript
		"jedi_language_server", -- Python (alternative: "pyright")
		"lua_ls",               -- Lua (essential for Neovim config)
		"emmet_ls",             -- HTML and CSS expansion
		"jsonls",               -- JSON
		"html",                 -- HTML
		"cssls",                -- CSS
		"yamlls",               -- YAML
		"dockerls",             -- Dockerfile
		"marksman",             -- Markdown
		"gopls",                -- Go language server (for Go support)
		-- "clangd",            -- C and C++ (uncomment if needed)
		-- "intelephense",      -- PHP (uncomment if needed)
		-- "rust_analyzer",     -- Rust (uncomment if needed)
	},

	automatic_installation = true, -- Automatically install language servers
}

return {
	"williamboman/mason-lspconfig.nvim",
	opts = opts,
	event = "BufReadPre",
	dependencies = "williamboman/mason.nvim",
}
