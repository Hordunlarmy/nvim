local config = function()
	local ok, ts_configs = pcall(require, "nvim-treesitter.configs")
	if not ok then
		-- Fallback for newer Treesitter or failing master branch
		local ok_ts, ts = pcall(require, "nvim-treesitter")
		if ok_ts then
			ts_configs = ts
		else
			return
		end
	end

	ts_configs.setup({
		build = ":TSUpdate",
		indent = {
			enable = true,
		},
		autotag = {
			enable = true,
		},
		event = {
			"BufReadPre",
			"BufNewFile",
		},
		ensure_installed = {
			"regex",
			"rust",
			"go",
			"gomod",
			"gowork",
			"markdown",
			"markdown_inline",
			"json",
			"javascript",
			"typescript",
			"yaml",
			"html",
			"css",
			"bash",
			"lua",
			"dockerfile",
			"solidity",
			"gitignore",
			"python",
			"vue",
			"svelte",
			"toml",
			"jsonc",
			"c",
			"cpp",
			"java",
			"clojure",
			"sql",
		},
		auto_install = true,
		highlight = {
			enable = true,
			additional_vim_regex_highlighting = true,
			disable = { "clojure" }, -- Disable clojure highlight to fix query errors
		},
		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = "<C-s>",
				node_incremental = "<C-s>",
				scope_incremental = false,
				node_decremental = "<BS>",
			},
		},
	})
end

return {
	"nvim-treesitter/nvim-treesitter",
	branch = "master",
	build = ":TSUpdate",
	lazy = false,
	config = config,
}
