-- Plugin load theme

return {
		{
		'projekt0n/github-nvim-theme',
		lazy = false,
		priority = 1000,
		config = function()
			require('github-theme').setup({
				options = {
					theme_style = 'dark_default',
					-- theme_style = 'dimmed',
					-- theme_style = 'light_default',
					-- theme_style = 'light_dimmed',
					-- theme_style = 'dark_dimmed',
					-- theme_style = 'dark_high_contrast',

					transparent = false,         -- For transparency
					hide_inactive_statusline = false, -- For hiding inactive status lines
					darken = {
						sidebars = {
							list = { 'qf', 'vista_kind', 'terminal', 'packer' } -- Sidebar settings
						}
					}
				},
				specs = {
					default = {
						border_highlight = 'bg' -- Custom color setting
					}
				}
			})

			vim.cmd('colorscheme github_dark')
		end
	},
}
