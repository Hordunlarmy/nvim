-- Plugin to show notifications

return {
	"folke/noice.nvim",
	event = "VeryLazy",
	opts = {
			messages = {
				enabled = true,
				view = "mini",
				view_error = "mini",
				view_warn = "mini",
				view_history = "popup",
			},
		notify = {
			enabled = false,
		},
		routes = {
			{
				filter = { event = "msg_showmode" },
				opts = { skip = true },
			},
		},

			views = {
				history_win = {
					backend = "popup",
					relative = "win",
					enter = true,
					position = "50%",
					size = {
						width = 0.90,
						height = 0.75,
					},
					border = {
						style = "rounded",
					},
				},
				cmdline_popup = {
					relative = "win",
					position = {
						row = "100%",
					col = "50%",
				},
				size = {
					width = 60,
					height = "auto",
				},
			},
			popupmenu = {
				relative = "win",
				position = {
					row = 8,
					col = "50%",
				},
				size = {
					width = 60,
					height = 10,
				},
				border = {
					style = "rounded",
					padding = { 0, 1 },
				},
				win_options = {
					winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
				},
			},
		},

			lsp = {
				progress = {
					enabled = false,
				},
			-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
				["cmp.entry.get_documentation"] = true,
			},
			hover = {
				enabled = false,
			},
			},
				commands = {
					history = {
						view = "history_win",
						opts = { enter = true, format = "details" },
					},
				},
			-- you can enable a preset for easier configuration
		presets = {
			bottom_search = true,      -- use a classic bottom cmdline for search
			command_palette = true,    -- position the cmdline and popupmenu together
			long_message_to_split = false, -- Keep messages in floating windows
			inc_rename = false,        -- enables an input dialog for inc-rename.nvim
			lsp_doc_border = false,    -- keep native LSP hover sizing behavior
		},
	},
	dependencies = {
		-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
		"MunifTanjim/nui.nvim",
		-- OPTIONAL:
		--   `nvim-notify` is only needed, if you want to use the notification view.
		--   If not available, we use `mini` as the fallback
		"rcarriga/nvim-notify",
	},
}
