local config = function()

	require("mason").setup({
    "mason-org/mason.nvim",
    opts = {
        ui = {
            icons = {
                package_installed = "✓",
                package_pending = "➜",
                package_uninstalled = "✗"
            },
				    border = "rounded",  -- White border
				    width = 0.85,        -- 85% of screen
				    height = 0.85,       -- 85% of screen
            backdrop = 100,      -- Opaque backdrop
		        keymaps = {
							---@since 1.0.0
							-- Keymap to expand a package
							toggle_package_expand = "<CR>",
							---@since 1.0.0
							-- Keymap to install the package under the current cursor position
							install_package = "i",
							---@since 1.0.0
							-- Keymap to reinstall/update the package under the current cursor position
							update_package = "u",
							---@since 1.0.0
							-- Keymap to check for new version for the package under the current cursor position
							check_package_version = "c",
							---@since 1.0.0
							-- Keymap to update all installed packages
							update_all_packages = "U",
							---@since 1.0.0
							-- Keymap to check which installed packages are outdated
							check_outdated_packages = "C",
							---@since 1.0.0
							-- Keymap to uninstall a package
							uninstall_package = "X",
							---@since 1.0.0
							-- Keymap to cancel a package installation
							cancel_installation = "<C-c>",
							---@since 1.0.0
							-- Keymap to apply language filter
							apply_language_filter = "<C-f>",
							---@since 1.1.0
							-- Keymap to toggle viewing package installation log
							toggle_package_install_log = "<CR>",
							---@since 1.8.0
							-- Keymap to toggle the help view
							toggle_help = "g?",
					},
        }
    }
})

end

return {
	"williamboman/mason.nvim",
	cmd = "Mason",
	event = "BufReadPre",
	config = config,
	opts = {
		ui = {
			icons = {
				package_installed = "✓",
				package_pending = "➜",
				package_uninstalled = "✗",
			},
		},
	},
}
