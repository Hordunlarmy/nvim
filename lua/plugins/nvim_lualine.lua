-- Plugin for statusline

local config = function()
    local lualine = require("lualine")
    local progress = require("util.progress")
    local ok_ticker, ticker = pcall(require, "util.notify_ticker")
    progress.setup()

    local guarded_names = {
        statusline = true,
        winbar = true,
        tabline = true,
    }

    local function sanitize_statusline(value)
        if type(value) ~= "string" then
            return value
        end
        return value:gsub("[%z\1-\31\127]", " ")
    end

    local ok_opts, nvim_opts = pcall(require, "lualine.utils.nvim_opts")
    if ok_opts and nvim_opts and type(nvim_opts.set) == "function" and not nvim_opts._statusline_guard then
        local raw_set = nvim_opts.set
        nvim_opts.set = function(name, val, opts)
            if guarded_names[name] then
                val = sanitize_statusline(val)
            end
            local ok_set, err = pcall(raw_set, name, val, opts)
            if ok_set then
                return
            end
            if guarded_names[name] and type(val) == "string" and tostring(err):find("E539", 1, true) then
                val = val:gsub("[^\32-\126]", " "):gsub("%s+", " ")
                pcall(raw_set, name, val, opts)
                return
            end
            error(err)
        end
        nvim_opts._statusline_guard = true
    end

    local function progress_busy_safe()
        local ok, value = pcall(progress.is_busy)
        if not ok then
            return false
        end
        return value == true
    end

    local function ticker_text_safe()
        if not ok_ticker then
            return ""
        end
        if type(ticker.statusline) ~= "function" then
            return ""
        end
        local max_width = math.max(26, math.floor(vim.o.columns * 0.30))
        local ok, text = pcall(ticker.statusline, max_width)
        if not ok or type(text) ~= "string" then
            return ""
        end
        return sanitize_statusline(text)
    end

    local function ticker_has_current_safe()
        if not ok_ticker or type(ticker.has_current) ~= "function" then
            return false
        end
        local ok, value = pcall(ticker.has_current)
        return ok and value == true
    end

    local function busy()
        return progress_busy_safe()
    end
    local function idle()
        return not progress_busy_safe()
    end

    lualine.setup({
        options = {
            theme = "onedark", -- cozynight, gruvbox, onedark, tokyonight
            icons_enabled = true,
            section_separators = { "", "" },
            component_separators = { "", "" },
            disabled_filetypes = {},
            always_divide_middle = false,
        },
        sections = {
            lualine_a = {
                { "mode", cond = idle },
            },
            lualine_b = {
                { "branch", cond = idle },
                { "diff", cond = idle },
                {
                    'diagnostics',
                    sources = { "nvim_diagnostic" },
                    symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
                    cond = idle,
                }
            },
            lualine_c = {
                {
                    progress.fullwidth_component,
                    cond = busy,
                    color = { fg = "#111111", bg = "#98c379", gui = "bold" },
                    padding = { left = 0, right = 0 },
                    separator = { left = "", right = "" },
                },
                {
                    function()
                        return ticker_text_safe()
                    end,
                    cond = function()
                        return idle() and ticker_has_current_safe()
                    end,
                },
            },
            lualine_x = {
                { "encoding", cond = idle },
            },
            lualine_y = {
                { "searchcount", cond = idle },
            },
            lualine_z = {
                { "location", cond = idle },
            },
        },
        inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = {},
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
