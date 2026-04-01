-- Plugin for statusline

local config = function()
    local lualine = require("lualine")
    local ok_ticker, ticker = pcall(require, "util.notify_ticker")

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
        -- Escape percent only for raw statusline payload from ticker.
        text = text:gsub("%%", "%%%%")
        return sanitize_statusline(text)
    end

    local function ticker_has_current_safe()
        if not ok_ticker or type(ticker.has_current) ~= "function" then
            return false
        end
        local ok, value = pcall(ticker.has_current)
        return ok and value == true
    end

    local function navic_location_safe()
        local ok_navic, navic = pcall(require, "nvim-navic")
        if not ok_navic or type(navic.is_available) ~= "function" then
            return ""
        end
        local ok_available, available = pcall(navic.is_available)
        if not ok_available or not available then
            return ""
        end
        local ok_location, location = pcall(navic.get_location)
        if not ok_location or type(location) ~= "string" or location == "" then
            return ""
        end
        return sanitize_statusline(location)
    end

    local function show_ticker()
        return ticker_has_current_safe()
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
                { "mode" },
            },
            lualine_b = {
                { "branch" },
                { "diff" },
                {
                    'diagnostics',
                    sources = { "nvim_diagnostic" },
                    symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
                }
            },
            lualine_c = {
                {
                    function()
                        return ticker_text_safe()
                    end,
                    cond = show_ticker,
                },
            },
            lualine_x = {
                { "encoding" },
            },
            lualine_y = {
                { "searchcount" },
            },
            lualine_z = {
                { "location" },
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
        winbar = {},
        inactive_winbar = {},
        tabline = {},
        extensions = { "nvim-tree" },
    })

    -- Keep global statusline stable even if plugins try to change it.
    local group = vim.api.nvim_create_augroup("LualineGlobalStatusGuard", { clear = true })
    vim.api.nvim_create_autocmd("VimEnter", {
        group = group,
        callback = function()
            if vim.o.laststatus ~= 3 then
                vim.o.laststatus = 3
            end
            pcall(lualine.refresh, { place = { "statusline" } })
        end,
    })
end

return {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        'nvim-tree/nvim-web-devicons',
        "SmiteshP/nvim-navic",
    },
    lazy = false,
    config = config,
}
