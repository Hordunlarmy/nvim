local keys = {
    { "<leader>/",  "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer search" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>",                   desc = "Buffers" },
    { "<A-f>",      "<cmd>Telescope find_files<cr>",                desc = "Find All Files" },
    { "<C-p>",      "<cmd>Telescope git_files<cr>",                 desc = "Git files" },
    { "<leader>fj", "<cmd>Telescope help_tags<cr>",                 desc = "Help" },
    { "<leader>fh", "<cmd>Telescope command_history<cr>",           desc = "History" },
    { "<leader>fk", "<cmd>Telescope keymaps<cr>",                   desc = "Keymaps" },
    { "<leader>fl", "<cmd>Telescope lsp_references<cr>",            desc = "Lsp References" },
    { "<leader>fo", "<cmd>Telescope oldfiles<cr>",                  desc = "Old files" },
    { "<C-f>",      "<cmd>Telescope live_grep<cr>",                 desc = "Ripgrep" },
    { "<leader>fs", "<cmd>Telescope grep_string<cr>",               desc = "Grep String" },
    { "<leader>ft", "<cmd>Telescope treesitter<cr>",                desc = "Treesitter" },
    { "<leader>fT", "<cmd>Telescope keymaps<cr>",                   desc = "Key Mappings" },
    { "<leader>ff", "<cmd>Telescope builtin<cr>",                   desc = "Show all builtin functions" },
    { "<leader>fq", "<cmd>Telescope quickfix<cr>",                  desc = "Quickfix" },
    { "<leader>fa", "<cmd>Telescope lsp_code_actions<cr>",          desc = "Code Actions" },
    { "<leader>fd", "<cmd>Telescope lsp_document_diagnostics<cr>",  desc = "Document Diagnostics" },
    { "<leader>fw", "<cmd>Telescope lsp_workspace_diagnostics<cr>", desc = "Workspace Diagnostics" },
    { "<leader>fD", "<cmd>Telescope lsp_definitions<cr>",           desc = "Word Definitions" },
}

local config = function()
    local telescope = require("telescope")
    telescope.setup({
        defaults = {
            borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },  -- White borders
            winblend = 0,  -- Opaque
            layout_strategy = "center",
            layout_config = {
                width = 0.85,
                height = 0.85,
                preview_cutoff = 1,
            },
        },
        pickers = {
            live_grep = {
                additional_args = function(_)
                    return { "--hidden", "--no-ignore-vcs" }
                end,
            },
            find_files = {
                additional_args = function(_)
                    return { "--hidden", "--no-ignore-vcs" }
                end,
            },
        },
        extensions = {
            fzf = {
                fuzzy = true,
                override_generic_sorter = true,
                override_file_sorter = true,
                case_mode = "smart_case",
            },
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
