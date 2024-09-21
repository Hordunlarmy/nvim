local keys = {
	{ "<leader>/",  "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer search" },
	{ "<leader>fb", "<cmd>Telescope buffers<cr>",                   desc = "Buffers" },
	{ "<leader>gc", "<cmd>Telescope git_commits<cr>",               desc = "Commits" },
	{ "<A-f>", "<cmd>Telescope find_files<cr>",											desc = "Find All Files" },
	{ "<C-p>",      "<cmd>Telescope git_files<cr>",                 desc = "Git files" },
	{ "<leader>fj", "<cmd>Telescope help_tags<cr>",                 desc = "Help" },
	{ "<leader>fh", "<cmd>Telescope command_history<cr>",           desc = "History" },
	{ "<leader>fk", "<cmd>Telescope keymaps<cr>",                   desc = "Keymaps" },
	{ "<leader>fl", "<cmd>Telescope lsp_references<cr>",            desc = "Lsp References" },
	{ "<leader>fo", "<cmd>Telescope oldfiles<cr>",                  desc = "Old files" },
	{ "<C-f>",      "<cmd>Telescope live_grep<cr>",                 desc = "Ripgrep" },
	{ "<leader>fs", "<cmd>Telescope grep_string<cr>",               desc = "Grep String" },
	{ "<leader>ft", "<cmd>Telescope treesitter<cr>",                desc = "Treesitter" },
	-- { "<C-k>",      "<cmd>Telescope man_pages<cr>",                 desc = "Man Pages"},
	{ "<leader>ft>",      "<cmd>Telescope keymaps<cr>",             desc = "Key Mappings"},
	{ "<leader>ff>",      "<cmd>Telescope builtin<cr>",             desc = "Show all builtin functions"},
	{ "<leader>fq>",      "<cmd>Telescope quickfix<cr>",            desc = "Quickfix"},
	{ "<leader>fa>",      "<cmd>Telescope lsp_code_actions<cr>",     desc = "Code Actions"},
	{ "<leader>fd>",      "<cmd>Telescope lsp_document_diagnostics<cr>", desc = "Document Diagnostics"},
	{ "<leader>fw>",      "<cmd>Telescope lsp_workspace_diagnostics<cr>",desc = "Workspace Diagnostics"},
	{ "<leader>fd>",      "<cmd>Telescope lsp_definitions<cr>",     desc = "Word Definitions"},
}

local config = function()
	local telescope = require("telescope")
	telescope.setup({
		pickers = {
			live_grep = {
				file_ignore_patterns = { "node_modules", ".venv" },
				additional_args = function(_)
					return { "--hidden", "--no-ignore-vcs" }
				end,
				hidden = true,
				no_ignore = true,
			},
			find_files = {
				file_ignore_patterns = { "node_modules", ".venv" },
				additional_args = function(_)
					return { "--hidden", "--no-ignore-vcs" }
				end,
				no_ignore = true,
				hidden = true,
			},
		},
		extensions = {
			"fzf",
		},
	})
	telescope.load_extension("fzf")
end

return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		{ "nvim-lua/plenary.nvim" },
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
		},
	},
	keys = keys,
	config = config,
}
