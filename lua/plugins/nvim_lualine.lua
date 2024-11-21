-- Plugin for statusline

local config = function()
    local lualine = require("lualine")

    lualine.setup({
        options = {
            theme = "onedark", -- cozynight, gruvbox, onedark, tokyonight
            icons_enabled = true,
            section_separators = { "", "" },
            component_separators = { "", "" },
            disabled_filetypes = {},
            always_divide_middle = true,
        },
        sections = {
            lualine_a = { 'mode' },
            lualine_b = { 'branch', 'diff',
                {
                    'diagnostics',
                    sources = { "nvim_diagnostic" },
                    symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' }
                }
            },
            lualine_c = { "filename" },
            lualine_x = { {
                'copilot',
                symbols = {
                    status = {
                        icons = {
                            enabled = " ",
                            sleep = " ",   -- auto-trigger disabled
                            disabled = " ",
                            warning = " ",
                            unknown = " "
                        },
                        hl = {
                            enabled = "#50FA7B",
                            sleep = "#AEB7D0",
                            disabled = "#6272A4",
                            warning = "#FFB86C",
                            unknown = "#FF5555"
                        }
                    },
                    spinners = require("copilot-lualine.spinners").dots,
                    spinner_color = "#6272A4"
                },
                show_colors = false,
                show_loading = true
            },
                'encoding', 'hostname' },
            lualine_y = { "searchcount" },
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
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    lazy = false,
    config = config,
}
