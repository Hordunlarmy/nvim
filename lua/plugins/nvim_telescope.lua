local function with_cursor(picker, picker_opts, theme_opts)
    return function()
        local theme = require("telescope.themes").get_cursor(vim.tbl_deep_extend("force", {
            layout_config = {
                width = 0.94,
                height = 0.78,
            },
        }, theme_opts or {}))
        require("telescope.builtin")[picker](vim.tbl_deep_extend("force", theme, picker_opts or {}))
    end
end

local keys = {
    { "<leader>/",  with_cursor("current_buffer_fuzzy_find"),            desc = "Buffer search" },
    { "<leader>fb", with_cursor("buffers"),                               desc = "Buffers" },
    { "<A-f>",      with_cursor("current_buffer_fuzzy_find"),             desc = "File search (current buffer)" },
    { "<M-f>",      with_cursor("current_buffer_fuzzy_find"),             desc = "File search (current buffer)" },
    { "<C-p>",      with_cursor("git_files"),                             desc = "Git files" },
    { "<leader>fj", with_cursor("help_tags"),                             desc = "Help" },
    { "<leader>fh", with_cursor("command_history", nil, { previewer = false }), desc = "History" },
    { "<leader>fk", with_cursor("keymaps", { show_plug = false }, { previewer = false }), desc = "Keymaps" },
    { "<leader>fl", with_cursor("lsp_references"),                        desc = "Lsp References" },
    { "<leader>fo", with_cursor("oldfiles"),                              desc = "Old files" },
    { "<C-f>",      with_cursor("live_grep"),                             desc = "Ripgrep" },
    { "<leader>fs", with_cursor("grep_string"),                           desc = "Grep String" },
    { "<leader>ft", with_cursor("treesitter"),                            desc = "Treesitter" },
    { "<leader>fT", with_cursor("keymaps", { show_plug = false }, { previewer = false }), desc = "Key Mappings" },
    { "<leader>ff", with_cursor("builtin"),                               desc = "Show all builtin functions" },
    { "<leader>fq", with_cursor("quickfix"),                              desc = "Quickfix" },
    { "<leader>fa", with_cursor("diagnostics", { bufnr = 0 }),           desc = "Buffer Diagnostics" },
    { "<leader>fd", with_cursor("diagnostics", { bufnr = 0 }),           desc = "Document Diagnostics" },
    { "<leader>fw", with_cursor("diagnostics"),                           desc = "Workspace Diagnostics" },
    { "<leader>fD", with_cursor("lsp_definitions"),                       desc = "Word Definitions" },
}

local config = function()
    local telescope = require("telescope")
    telescope.setup({
        defaults = {
            borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },  -- White borders
            winblend = 0,  -- Opaque
            layout_config = {
                width = 0.8,
                height = 0.5,
                preview_cutoff = 60,
            },
        },
        pickers = {
            live_grep = {
                additional_args = function(_)
                    return { "--hidden", "--no-ignore-vcs" }
                end,
            },
            find_files = {
                hidden = true,
                no_ignore = true,
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
