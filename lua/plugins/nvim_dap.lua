local debugging_signs = require("util.icons").debugging_signs

return {
	"mfussenegger/nvim-dap",
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		-- set custom icons
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
					[vim.diagnostic.severity.ERROR] = debugging_signs.Error,
					[vim.diagnostic.severity.WARN] = debugging_signs.Warn,
					[vim.diagnostic.severity.INFO] = debugging_signs.Info,
					[vim.diagnostic.severity.HINT] = debugging_signs.Hint,
				}
			},
		})

		-- setup dap
		dapui.setup()

		-- add event listeners
		dap.listeners.after.event_initialized["dapui_config"] = function()
			dapui.open()
			vim.cmd("Hardtime disable")
			vim.cmd("NvimTreeClose")
		end

		dap.listeners.before.event_terminated["dapui_config"] = function()
			dapui.close()
			vim.cmd("Hardtime enable")
		end

		dap.listeners.before.event_exited["dapui_config"] = function()
			dapui.close()
			vim.cmd("Hardtime enable")
		end
	end,
	dependencies = "rcarriga/nvim-dap-ui",
}
