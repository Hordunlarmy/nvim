local opts = {
	ensure_installed = {
		"efm",          -- General purpose language server, can be used for linting and formatting
		"bashls",       -- Language server for Bash scripts
		"tsserver",     -- Language server for TypeScript and JavaScript
		"jedi_language_server", -- Language server for Python (replaces pyright)
		"lua_ls",       -- Language server for Lua
		"emmet_ls",     -- Language server for Emmet, useful for HTML and CSS
		"jsonls",       -- Language server for JSON
		"clangd",       -- Language server for C and C++
	},

	automatic_installation = true, -- Automatically install language servers
}

return {
	"williamboman/mason-lspconfig.nvim",
	opts = opts,
	event = "BufReadPre",
	dependencies = "williamboman/mason.nvim",
}

