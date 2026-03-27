return {
	"williamboman/mason.nvim",
	cmd = "Mason",
	event = "BufReadPre",
	config = function(_, opts)
		require("mason").setup(opts)

		local function open_mason_log_float()
			local log = require("mason-core.log")
			local path = log.outfile
			local bufnr = vim.fn.bufadd(path)
			vim.fn.bufload(bufnr)

			vim.bo[bufnr].buflisted = false
			vim.bo[bufnr].bufhidden = "wipe"
			vim.bo[bufnr].modifiable = false
			vim.bo[bufnr].readonly = true

			local anchor = vim.api.nvim_get_current_win()
			local anchor_w = vim.api.nvim_win_get_width(anchor)
			local anchor_h = vim.api.nvim_win_get_height(anchor)
			local width = math.min(anchor_w, math.max(80, math.floor(anchor_w * 0.88)))
			local height = math.min(anchor_h, math.max(18, math.floor(anchor_h * 0.82)))
			local row = math.max(0, math.floor((anchor_h - height) / 2))
			local col = math.max(0, math.floor((anchor_w - width) / 2))

			local win = vim.api.nvim_open_win(bufnr, true, {
				relative = "win",
				win = anchor,
				row = row,
				col = col,
				width = width,
				height = height,
				style = "minimal",
				border = "rounded",
			})

			vim.wo[win].wrap = false
			vim.wo[win].cursorline = true
		end

		pcall(vim.api.nvim_del_user_command, "MasonLog")
		vim.api.nvim_create_user_command("MasonLog", open_mason_log_float, {
			desc = "Opens the mason.nvim log in a floating window.",
		})
	end,
	opts = {
		ui = {
			border = "rounded",
			width = 0.85,
			height = 0.85,
			backdrop = 100,
			icons = {
				package_installed = "✓",
				package_pending = "➜",
				package_uninstalled = "✗",
			},
			keymaps = {
				toggle_package_expand = "<CR>",
				install_package = "i",
				update_package = "u",
				check_package_version = "c",
				update_all_packages = "U",
				check_outdated_packages = "C",
				uninstall_package = "X",
				cancel_installation = "<C-c>",
				apply_language_filter = "<C-f>",
				toggle_package_install_log = "<CR>",
				toggle_help = "g?",
			},
		},
	},
}
