local config = function()
	local lualine = require("lualine")

	lualine.setup({
		options = {
			theme = "onedark",
			icons_enabled = true,
			section_separators = { "", "" },
			component_separators = { "", "" },
			disabled_filetypes = {},
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = { "branch" },
			lualine_c = { "filename" },
			lualine_x = { "encoding", "fileformat", "filetype" },
			lualine_y = { "progress" },
			lualine_z = { "location" },
		},
		inactive_sections = {
			lualine_a = {},
			lualine_b = {},
			lualine_c = { "filename" },
			lualine_x = { "location" },
			lualine_y = {},
			lualine_z = {},
		},
		tabline = {},
		extensions = { "nvim-tree" },
	})
end

return {
	"nvim-lualine/lualine.nvim",
	lazy = false,
	config = config,
}
