return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  dependencies = { "nvim-tree/nvim-web-devicons", "folke/persistence.nvim" },
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")
    local function tb(name, opts)
      local ok, builtin = pcall(require, "telescope.builtin")
      if not ok or type(builtin[name]) ~= "function" then
        vim.notify("Telescope is unavailable", vim.log.levels.WARN)
        return
      end
      builtin[name](opts or {})
    end

    -- Larger, cleaner logo/header.
    dashboard.section.header.val = {
      "                                                     ",
      "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ██╗ ",
      "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗  ██║ ",
      "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔██╗ ██║ ",
      "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╗██║ ",
      "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚████║ ",
      "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝  ╚═══╝ ",
      "                                                     ",
    }

    dashboard.section.buttons.val = {
      dashboard.button("f", "  Find file", "<cmd>lua require('telescope.builtin').find_files()<CR>"),
      dashboard.button("r", "  Recent files", "<cmd>lua require('telescope.builtin').oldfiles()<CR>"),
      dashboard.button("c", "  Config", "<cmd>cd ~/.config/nvim | e $MYVIMRC | NvimTreeRefresh<CR>"),
      dashboard.button(
        "s",
        "  Restore session",
        "<cmd>lua if _G.restore_session_with_plugins then _G.restore_session_with_plugins() else require('persistence').load() end<CR>"
      ),
      dashboard.button("g", "  Find text", "<cmd>lua require('telescope.builtin').live_grep()<CR>"),
      dashboard.button("n", "  New file", "<cmd>ene <BAR> startinsert<CR>"),
      dashboard.button("l", "  Lazy", "<cmd>Lazy<CR>"),
      dashboard.button("q", "  Quit", "<cmd>qa<CR>"),
    }

    local function footer()
      local total_plugins = require("lazy").stats().count
      local version = vim.version()
      local datetime = os.date("%d-%m-%Y  %H:%M")
      return string.format("%s  •  %d plugins  •  v%d.%d.%d", datetime, total_plugins, version.major, version.minor, version.patch)
    end

    dashboard.section.footer.val = footer()
    dashboard.section.buttons.opts.spacing = 1
    dashboard.section.header.opts.hl = "Type"
    dashboard.section.buttons.opts.hl = "Keyword"
    dashboard.section.footer.opts.hl = "Comment"

    -- Official dashboard setup pattern from alpha README: require("alpha").setup(dashboard.opts)
    dashboard.opts.opts.noautocmd = true
    alpha.setup(dashboard.opts)

    local function map_dashboard_keys(bufnr)
      local opts = { buffer = bufnr, noremap = true, silent = true, nowait = true }
      vim.keymap.set("n", "f", function() tb("find_files") end, opts)
      vim.keymap.set("n", "r", function() tb("oldfiles") end, opts)
      vim.keymap.set("n", "c", "<cmd>cd ~/.config/nvim | e $MYVIMRC | NvimTreeRefresh<CR>", opts)
      vim.keymap.set(
        "n",
        "s",
        "<cmd>lua if _G.restore_session_with_plugins then _G.restore_session_with_plugins() else require('persistence').load() end<CR>",
        opts
      )
      vim.keymap.set("n", "g", function() tb("live_grep") end, opts)
      vim.keymap.set("n", "n", "<cmd>ene <BAR> startinsert<CR>", opts)
      vim.keymap.set("n", "l", "<cmd>Lazy<CR>", opts)
      vim.keymap.set("n", "q", "<cmd>qa<CR>", opts)
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "alpha",
      callback = function(event)
        vim.opt_local.foldenable = false
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        map_dashboard_keys(event.buf)
      end,
    })

    if vim.bo.filetype == "alpha" then
      map_dashboard_keys(vim.api.nvim_get_current_buf())
    end
  end,
}
