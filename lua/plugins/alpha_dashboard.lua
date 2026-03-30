return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "folke/persistence.nvim",
    { "nhattVim/alpha-ascii.nvim", opts = { header = "random" } },
  },
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")
    local telescope_themes = require("telescope.themes")

    local function tb(name, opts)
      local ok, builtin = pcall(require, "telescope.builtin")
      if not ok or type(builtin[name]) ~= "function" then
        vim.notify("Telescope is unavailable", vim.log.levels.WARN)
        return
      end
      local anchor_win = vim.api.nvim_get_current_win()
      local anchor_w = vim.api.nvim_win_get_width(anchor_win)
      local anchor_h = vim.api.nvim_win_get_height(anchor_win)
      local clean_dropdown = telescope_themes.get_dropdown({
        previewer = false,
        layout_strategy = "center",
        layout_config = {
          width = math.max(52, math.floor(anchor_w * 0.82)),
          height = math.max(12, math.floor(anchor_h * 0.58)),
        },
      })
      local final_opts = vim.tbl_deep_extend("force", clean_dropdown, opts or {})
      builtin[name](final_opts)
    end

    pcall(vim.api.nvim_del_user_command, "AlphaFindFiles")
    pcall(vim.api.nvim_del_user_command, "AlphaRecentFiles")
    pcall(vim.api.nvim_del_user_command, "AlphaLiveGrep")
    vim.api.nvim_create_user_command("AlphaFindFiles", function()
      tb("find_files")
    end, {})
    vim.api.nvim_create_user_command("AlphaRecentFiles", function()
      tb("oldfiles")
    end, {})
    vim.api.nvim_create_user_command("AlphaLiveGrep", function()
      tb("live_grep")
    end, {})

    local quotes = {
      "What we assembled with trembling hands, rose to question its maker.",
      "The interface is quiet. The ideas are not.",
      "Precision over noise. Focus over frenzy.",
      "Write less. Mean more.",
      "Tools fade. Craft remains.",
      "A sharp editor reveals dull thinking.",
      "Small feedback loops build large systems.",
      "Clean edges, ruthless intent.",
      "Every keystroke is a design decision.",
      "Speed is earned by clarity.",
    }
    math.randomseed(os.time() + (vim.loop and math.floor(vim.loop.hrtime() % 1000000) or 0))
    local quote = quotes[math.random(1, #quotes)]

    local message = {
      type = "text",
      val = quote,
      opts = { hl = "Comment", position = "center" },
    }

    local function pad_right(text, width)
      local len = vim.fn.strdisplaywidth(text)
      if len >= width then
        return text
      end
      return text .. string.rep(" ", width - len)
    end

    local function grid_line(left, right)
      local l = pad_right(left, 22)
      local r = pad_right(right, 22)
      return " " .. l .. " | " .. r
    end

    local command_grid = {
      type = "group",
      val = {
        { type = "text", val = " ┌────────────────────────┬────────────────────────┐", opts = { position = "center", hl = "Comment" } },
        { type = "text", val = grid_line("[f] Find Files", "[r] Recent Files"), opts = { position = "center", hl = "Comment" } },
        { type = "text", val = grid_line("[g] Find Text", "[c] Config"), opts = { position = "center", hl = "Comment" } },
        { type = "text", val = grid_line("[s] Restore Session", "[n] New File"), opts = { position = "center", hl = "Comment" } },
        { type = "text", val = grid_line("[l] Lazy", "[q] Quit"), opts = { position = "center", hl = "Comment" } },
        { type = "text", val = " └────────────────────────┴────────────────────────┘", opts = { position = "center", hl = "Comment" } },
      },
      opts = { spacing = 0 },
    }

    local function footer()
      local stats = require("lazy").stats()
      local version = vim.version()
      return string.format(
        "%s  •  %d plugins  •  %.2fms  •  v%d.%d.%d",
        os.date("%d-%m-%Y  %H:%M"),
        stats.count,
        stats.startuptime,
        version.major,
        version.minor,
        version.patch
      )
    end

    local screen_lines = vim.o.lines
    local show_message = screen_lines >= 20
    local show_footer = screen_lines >= 24

    dashboard.section.header.opts.hl = "Comment"
    dashboard.section.footer.val = show_footer and footer() or ""
    dashboard.section.footer.opts.hl = "Comment"

    local layout = {
      { type = "padding", val = 0 },
      dashboard.section.header,
      { type = "padding", val = 0 },
    }
    if show_message then
      layout[#layout + 1] = { type = "padding", val = 2 }
      layout[#layout + 1] = message
      layout[#layout + 1] = { type = "padding", val = 0 }
    end
    layout[#layout + 1] = command_grid
    if show_footer then
      layout[#layout + 1] = { type = "padding", val = 0 }
      layout[#layout + 1] = dashboard.section.footer
    end
    dashboard.config.layout = layout

    dashboard.opts.opts.noautocmd = true
    alpha.setup(dashboard.opts)

    -- Replace header with alpha-ascii random header set.
    local ok_ascii, ascii = pcall(require, "alpha_ascii")
    if ok_ascii and ascii and type(ascii.setup) == "function" then
      ascii.setup({ header = "random" })
    end

    local function constrain_header_size()
      local header = dashboard.config.layout[2]
      if type(header) ~= "table" or type(header.val) ~= "table" then
        return
      end

      header.opts = header.opts or {}
      header.opts.position = "center"
      header.opts.hl = "Comment"

      local max_width = math.max(56, math.floor(vim.o.columns * 0.68))
      local max_lines = math.max(4, vim.o.lines - (show_message and 15 or 13))

      local clipped = {}
      for _, line in ipairs(header.val) do
        clipped[#clipped + 1] = vim.fn.strcharpart(line, 0, max_width)
      end

      if #clipped > max_lines then
        local start_idx = math.floor((#clipped - max_lines) / 2) + 1
        local limited = {}
        for i = start_idx, math.min(#clipped, start_idx + max_lines - 1) do
          limited[#limited + 1] = clipped[i]
        end
        clipped = limited
      end

      header.val = clipped
    end
    constrain_header_size()
    pcall(vim.cmd.AlphaRedraw)

    local function map_dashboard_keys(bufnr)
      local opts = { buffer = bufnr, noremap = true, silent = true, nowait = true }
      vim.keymap.set("n", "f", function() tb("find_files") end, opts)
      vim.keymap.set("n", "r", function() tb("oldfiles", { previewer = false, prompt_title = "Recent Files" }) end, opts)
      vim.keymap.set("n", "g", function() tb("live_grep") end, opts)
      vim.keymap.set("n", "c", "<cmd>cd ~/.config/nvim | e $MYVIMRC | NvimTreeRefresh<CR>", opts)
      vim.keymap.set(
        "n",
        "s",
        "<cmd>lua if _G.restore_session_with_plugins then _G.restore_session_with_plugins() else require('persistence').load() end<CR>",
        opts
      )
      vim.keymap.set("n", "n", "<cmd>ene <BAR> startinsert<CR>", opts)
      vim.keymap.set("n", "l", "<cmd>Lazy<CR>", opts)
      vim.keymap.set("n", "q", "<cmd>quit<CR>", opts)
    end

    vim.api.nvim_create_autocmd("User", {
      pattern = "AlphaReady",
      callback = function()
        vim.opt_local.fillchars = { eob = " " }
        constrain_header_size()
        local bufnr = vim.api.nvim_get_current_buf()
        if vim.bo[bufnr].filetype == "alpha" then
          map_dashboard_keys(bufnr)
        end
      end,
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "alpha",
      callback = function(event)
        vim.opt_local.foldenable = false
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        map_dashboard_keys(event.buf)
      end,
    })

    -- If a real file opens (e.g. from NvimTree), close any visible Alpha window in this tab.
    local function is_real_file_buffer(bufnr)
      if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
        return false
      end
      local ft = vim.bo[bufnr].filetype
      local bt = vim.bo[bufnr].buftype
      local name = vim.api.nvim_buf_get_name(bufnr)
      if ft == "alpha" or ft == "NvimTree" or ft == "aerial" then
        return false
      end
      return bt == "" and name ~= "" and not name:match("^term://")
    end

    vim.api.nvim_create_autocmd({ "BufWinEnter", "BufEnter" }, {
      group = vim.api.nvim_create_augroup("AlphaCloseOnRealFile", { clear = true }),
      callback = function(args)
        if not is_real_file_buffer(args.buf) then
          return
        end
        local current_win = vim.api.nvim_get_current_win()
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          if win ~= current_win and vim.api.nvim_win_is_valid(win) then
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == "alpha" then
              pcall(vim.api.nvim_win_close, win, true)
            end
          end
        end
      end,
    })

    if vim.bo.filetype == "alpha" then
      map_dashboard_keys(vim.api.nvim_get_current_buf())
    end
  end,
}
