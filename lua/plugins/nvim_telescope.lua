-- Keep pickers in one centred window.  The old `cursor` theme creates a
-- separate prompt/results pair, which is especially confusing for a fuzzy
-- search of the buffer already visible behind it.
local function with_picker(picker, picker_opts, layout_opts)
    return function()
        local opts = vim.tbl_deep_extend("force", {
            layout_strategy = "horizontal",
            sorting_strategy = "ascending",
            layout_config = {
                width = 0.78,
                height = 0.66,
                prompt_position = "top",
                preview_width = 0.52,
            },
        }, layout_opts or {}, picker_opts or {})
        require("telescope.builtin")[picker](opts)
    end
end

local function fuzzy_buffer()
    return with_picker("current_buffer_fuzzy_find", nil, {
        layout_config = {
            width = 0.70,
            height = 0.58,
            prompt_position = "top",
        },
        previewer = false,
    })
end

local keys = {
    { "<leader>/",  fuzzy_buffer(),                                        desc = "Search current buffer" },
    { "<leader>fb", with_picker("buffers"),                               desc = "Buffers" },
    { "<A-f>",      fuzzy_buffer(),                                        desc = "Search current buffer" },
    { "<M-f>",      fuzzy_buffer(),                                        desc = "Search current buffer" },
    { "<C-p>",      with_picker("git_files"),                             desc = "Git files" },
    { "<leader>fj", with_picker("help_tags"),                             desc = "Help" },
    { "<leader>fh", with_picker("command_history", nil, { previewer = false }), desc = "History" },
    { "<leader>fk", with_picker("keymaps", { show_plug = false }, { previewer = false }), desc = "Keymaps" },
    { "<leader>fl", with_picker("lsp_references"),                        desc = "LSP references" },
    { "<leader>fo", with_picker("oldfiles"),                              desc = "Recent files" },
    { "<C-f>",      with_picker("live_grep"),                             desc = "Search project text" },
    { "<leader>fs", with_picker("grep_string"),                           desc = "Search word under cursor" },
    { "<leader>ft", with_picker("treesitter"),                            desc = "Document symbols" },
    { "<leader>fT", with_picker("keymaps", { show_plug = false }, { previewer = false }), desc = "Key mappings" },
    { "<leader>ff", with_picker("find_files", { hidden = true, no_ignore = true }), desc = "Find files" },
    { "<leader>fB", with_picker("builtin", nil, { previewer = false }),   desc = "Telescope commands" },
    { "<leader>fq", with_picker("quickfix"),                              desc = "Quickfix" },
    { "<leader>fa", with_picker("diagnostics", { bufnr = 0 }),           desc = "Buffer diagnostics" },
    { "<leader>fd", with_picker("diagnostics", { bufnr = 0 }),           desc = "Document diagnostics" },
    { "<leader>fw", with_picker("diagnostics"),                           desc = "Workspace diagnostics" },
    { "<leader>fD", with_picker("lsp_definitions"),                       desc = "Word definitions" },
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
