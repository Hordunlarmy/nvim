-- Plugin to show diagnostics in a list

local diagnostic_signs = require("util.icons").diagnostic_signs
local maplazykey = require("util.keymapper").maplazykey

return {
	"folke/trouble.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		position = "bottom",
		height = 15,
		icons = true,
		mode = "workspace_diagnostics",
		fold_open = "",
		fold_closed = "",
		group = true,
		padding = true,
		action_keys = {
			close = "q",
			cancel = "<esc>",
			refresh = "r",
			jump = {"<cr>", "<tab>"},
			open_split = { "<c-x>" },
			open_vsplit = { "<c-v>" },
			open_tab = { "<c-t>" },
			jump_close = {"o"},
			toggle_mode = "m",
			toggle_preview = "P",
			hover = "K",
			preview = "p",
			close_folds = {"zM", "zm"},
			open_folds = {"zR", "zr"},
			toggle_fold = {"zA", "za"},
			previous = "k",
			next = "j"
		},
		indent_lines = true,
		auto_open = false,
		auto_close = false,
		auto_preview = true,
		auto_fold = false,
		auto_jump = {"lsp_definitions"},
		signs = {
			error = diagnostic_signs.Error,
			warning = diagnostic_signs.Warn,
			hint = diagnostic_signs.Hint,
			information = diagnostic_signs.Info,
			other = diagnostic_signs.Info,
		},
		use_diagnostic_signs = true,
	},
	keys = {
		maplazykey("<leader>xx", function()
			require("trouble").toggle()
		end, "Toggle Trouble"),
		maplazykey("<leader>xw", function()
			require("trouble").toggle("workspace_diagnostics")
		end, "Show Workspace Diagnostics"),
		maplazykey("<leader>xd", function()
			require("trouble").toggle("document_diagnostics")
		end, "Show Document Diagnostics"),
		maplazykey("<leader>xq", function()
			require("trouble").toggle("quickfix")
		end, "Toggle Quickfix List"),
		maplazykey("<leader>xl", function()
			require("trouble").toggle("loclist")
		end, "Toggle Location List"),
		maplazykey("gR", function()
			require("trouble").toggle("lsp_references")
		end, "Toggle LSP References"),
	},
}
