-- aerial: Code outline window for symbols
return {
  "stevearc/aerial.nvim",
  lazy = false,
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local excluded_filetypes = {
      help = true,
      qf = true,
      NvimTree = true,
      alpha = true,
      dashboard = true,
      starter = true,
      lazy = true,
      mason = true,
      spectre_panel = true,
      toggleterm = true,
      aerial = true,
      TelescopePrompt = true,
      ["neo-tree"] = true,
      Trouble = true,
      trouble = true,
      notify = true,
      oil = true,
      fugitive = true,
      gitcommit = true,
    }

    local function should_auto_open(bufnr)
      if vim.t.conjure_log_visible then
        local has_conjure_log_win = false
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          local b = vim.api.nvim_win_get_buf(win)
          local name = vim.api.nvim_buf_get_name(b)
          if name and name:match("conjure%-log%-") then
            has_conjure_log_win = true
            break
          end
        end
        if has_conjure_log_win then
          return false
        end
        vim.t.conjure_log_visible = false
      end
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local b = vim.api.nvim_win_get_buf(win)
        if vim.bo[b].filetype == "sidekick_terminal" then
          return false
        end
      end
      if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
        return false
      end

      local buftype = vim.bo[bufnr].buftype
      local filetype = vim.bo[bufnr].filetype
      if buftype ~= "" or excluded_filetypes[filetype] then
        return false
      end

      local name = vim.api.nvim_buf_get_name(bufnr)
      if name:match("^term://") or name:match("conjure%-log%-") then
        return false
      end

      local line_count = vim.api.nvim_buf_line_count(bufnr)
      if line_count > 5000 then
        return false
      end

      if name ~= "" then
        local file_size = vim.fn.getfsize(name)
        if file_size > 0 and file_size > 512000 then
          return false
        end
      end

      return true
    end

    local function aerial_open_in_tab(tabnr)
      tabnr = tabnr or 0
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabnr)) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "aerial" then
          return true
        end
      end
      return false
    end

    require("aerial").setup({
    backends = {
      _ = { "lsp", "treesitter" },
      sql = { "lsp" },
      mysql = { "lsp" },
      plsql = { "lsp" },
    },
    -- Prefer LSP for Clojure to recognize custom macros like defapi
    prefer_treesitter = false,
    layout = {
      max_width = { 40, 0.2 },
      width = 32,
      min_width = 28,
      win_opts = {},
      default_direction = "right",  -- Always open on right
      placement = "window",
      resize_to_content = false,
      preserve_equality = false,
    },
    attach_mode = "window",
    -- Keep panel stable across filetypes; don't auto-close when backend is missing.
    close_automatic_events = {},
    keymaps = {
      ["?"] = "actions.show_help",
      ["g?"] = "actions.show_help",
      ["<CR>"] = "actions.jump",
      ["<2-LeftMouse>"] = "actions.jump",
      ["<C-v>"] = "actions.jump_vsplit",
      ["<C-s>"] = "actions.jump_split",
      ["p"] = "actions.scroll",
      ["<C-j>"] = "actions.down_and_scroll",
      ["<C-k>"] = "actions.up_and_scroll",
      ["{"] = "actions.prev",
      ["}"] = "actions.next",
      ["[["] = "actions.prev_up",
      ["]]"] = "actions.next_up",
      ["q"] = false,  -- Disable default, we'll set custom below
      ["<ESC>"] = false,  -- Disable default, we'll set custom below
      ["o"] = "actions.tree_toggle",
      ["za"] = "actions.tree_toggle",
      ["O"] = "actions.tree_toggle_recursive",
      ["zA"] = "actions.tree_toggle_recursive",
      ["l"] = "actions.tree_open",
      ["zo"] = "actions.tree_open",
      ["L"] = "actions.tree_open_recursive",
      ["zO"] = "actions.tree_open_recursive",
      ["h"] = "actions.tree_close",
      ["zc"] = "actions.tree_close",
      ["H"] = "actions.tree_close_recursive",
      ["zC"] = "actions.tree_close_recursive",
      ["zr"] = "actions.tree_increase_fold_level",
      ["zR"] = "actions.tree_open_all",
      ["zm"] = "actions.tree_decrease_fold_level",
      ["zM"] = "actions.tree_close_all",
      ["zx"] = "actions.tree_sync_folds",
      ["zX"] = "actions.tree_sync_folds",
    },
    lazy_load = false,
    disable_max_lines = 10000,
    disable_max_size = 2000000,
    filter_kind = {
      _ = {
        "Class",
        "Constructor",
        "Enum",
        "Function",
        "Interface",
        "Module",
        "Method",
        "Struct",
      },
      sql = false,
      mysql = false,
      plsql = false,
    },
    highlight_mode = "split_width",
    highlight_closest = true,
    highlight_on_hover = false,
    highlight_on_jump = 300,
    icons = {},
    ignore = {
      unlisted_buffers = true,
      filetypes = {},
      buftypes = "special",
      wintypes = "special",
    },
    manage_folds = false,
    link_folds_to_tree = false,
    link_tree_to_folds = true,
    nerd_font = "auto",
    on_attach = function(bufnr) end,
    -- We drive auto-open via an explicit BufEnter autocmd below for determinism.
    on_first_symbols = nil,
    open_automatic = false,
    post_jump_cmd = "normal! zz",
    close_on_select = false,
    update_events = "BufWritePost,InsertLeave",
    show_guides = true,
    guides = {
      mid_item = "├─",
      last_item = "└─",
      nested_top = "│ ",
      whitespace = "  ",
    },
    get_highlight = function(symbol, is_icon, is_collapsed)
      return "Aerial" .. symbol.kind .. (is_icon and "Icon" or "")
    end,
    lsp = {
      diagnostics_trigger_update = false,
      update_when_errors = false,
      update_delay = 300,
    },
    treesitter = {
      update_delay = 600,
      -- Custom queries for Clojure to recognize defapi and other custom macros
      experimental_selection_range = true,
    },
    -- Add custom symbol kinds for Clojure macros
    post_parse_symbol = function(bufnr, item, ctx)
      -- Treat defapi, defroutes, etc. as Functions in Aerial
      if vim.bo[bufnr].filetype == "clojure" then
        if item.kind == "Variable" and item.name then
          -- Check if this is a custom macro definition
          local line = vim.api.nvim_buf_get_lines(bufnr, item.lnum - 1, item.lnum, false)[1]
          if line and line:match("%(def[a-z]+%s+" .. vim.pesc(item.name)) then
            item.kind = "Function"
          end
        end
      end
      return true
    end,
    markdown = {
      update_delay = 300,
    },
    man = {
      update_delay = 300,
    },
  })
    
    -- Set keymaps manually with graceful fallback when no backend is available.
    vim.keymap.set("n", "<leader>o", function()
      -- Manual toggle should always work even if sidekick previously owned the right panel.
      vim.t.sidekick_active = false
      local ok_aerial, aerial = pcall(require, "aerial")
      if not ok_aerial then
        vim.notify("Aerial outline unavailable for this buffer", vim.log.levels.WARN)
        return
      end
      if aerial_open_in_tab(0) then
        pcall(aerial.close)
        return
      end

      -- Prefer explicit open on the right; fallback to API open.
      local ok = pcall(vim.cmd, "AerialOpen right")
      if not ok then
        ok = pcall(aerial.open, { focus = false })
      end
      if not ok then
        vim.notify("Aerial outline unavailable for this buffer", vim.log.levels.WARN)
      end
    end, { desc = "Toggle Outline (Aerial)" })

    vim.keymap.set("n", "<leader>O", function()
      local ok = pcall(vim.cmd, "AerialNavToggle")
      if not ok then
        vim.notify("Aerial nav unavailable: no symbols/backend for this buffer", vim.log.levels.WARN)
      end
    end, { desc = "Aerial Navigation Float" })
    
    -- Set custom close keymaps that handle last window gracefully
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "aerial",
      callback = function(args)
        local bufnr = args.buf
        
        -- Safe close function
        local function safe_aerial_close()
          local wins = vim.api.nvim_list_wins()
          local valid_wins = 0
          for _, win in ipairs(wins) do
            if vim.api.nvim_win_get_config(win).relative == "" then
              valid_wins = valid_wins + 1
            end
          end
          
          if valid_wins > 1 then
            -- Safe to close aerial
            require("aerial").close()
          else
            -- Last window, don't close (would error)
            vim.notify("Cannot close last window", vim.log.levels.WARN, { timeout = 1000 })
          end
        end
        
        -- Set buffer-local keymaps
        vim.keymap.set("n", "q", safe_aerial_close, { buffer = bufnr, desc = "Close Aerial (safe)" })
      end,
    })

    local auto_group = vim.api.nvim_create_augroup("AerialAutoOpenSinglePane", { clear = true })
    vim.api.nvim_create_autocmd("BufEnter", {
      group = auto_group,
      callback = function(args)
        local bufnr = args.buf
        if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
          return
        end
        vim.defer_fn(function()
          if not vim.api.nvim_buf_is_valid(bufnr) then
            return
          end
          if vim.api.nvim_get_current_buf() ~= bufnr then
            return
          end
          if not should_auto_open(bufnr) then
            return
          end
          if aerial_open_in_tab(0) then
            return
          end
          local ok = pcall(vim.cmd, "AerialOpen right")
          if not ok then
            local ok_aerial, aerial = pcall(require, "aerial")
            if ok_aerial then
              pcall(aerial.open, { focus = false })
            end
          end
        end, 80)
      end,
    })

  end,
}
