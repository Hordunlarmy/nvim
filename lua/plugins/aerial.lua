-- aerial: Code outline window for symbols
return {
  "stevearc/aerial.nvim",
  lazy = false,  -- Load on startup
  event = "VeryLazy",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("aerial").setup({
    backends = { "treesitter", "lsp", "markdown", "man" },
    layout = {
      max_width = { 40, 0.2 },
      width = nil,
      min_width = 30,
      win_opts = {},
      default_direction = "right",  -- Always open on right
      placement = "window",
      resize_to_content = true,
      preserve_equality = false,
    },
    attach_mode = "global",  -- Changed from "window" to "global"
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
    lazy_load = true,
    disable_max_lines = 10000,
    disable_max_size = 2000000,
    filter_kind = {
      "Class",
      "Constructor",
      "Enum",
      "Function",
      "Interface",
      "Module",
      "Method",
      "Struct",
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
    on_first_symbols = function(bufnr) end,
    open_automatic = false,
    post_jump_cmd = "normal! zz",
    close_on_select = false,
    update_events = "TextChanged,InsertLeave",
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
      diagnostics_trigger_update = true,
      update_when_errors = true,
      update_delay = 300,
    },
    treesitter = {
      update_delay = 300,
    },
    markdown = {
      update_delay = 300,
    },
    man = {
      update_delay = 300,
    },
  })
    
    -- Set keymaps manually
    vim.keymap.set("n", "<leader>o", "<cmd>AerialToggle!<cr>", { desc = "Toggle Outline (Aerial)" })
    vim.keymap.set("n", "<leader>O", "<cmd>AerialNavToggle<cr>", { desc = "Aerial Navigation Float" })
    
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
        vim.keymap.set("n", "<ESC>", safe_aerial_close, { buffer = bufnr, desc = "Close Aerial (safe)" })
      end,
    })
    
    -- Auto-open Aerial when entering a buffer with code
    vim.api.nvim_create_autocmd("BufWinEnter", {
      group = vim.api.nvim_create_augroup("AerialAutoOpen", { clear = true }),
      callback = function(args)
        local bufnr = args.buf
        local filetype = vim.bo[bufnr].filetype
        local buftype = vim.bo[bufnr].buftype
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        
        -- Skip if no filename
        if bufname == "" or bufname:match("^term://") then
          return
        end
        
        -- List of filetypes to exclude
        local excluded_filetypes = {
          "", "help", "qf", "NvimTree", "alpha", "dashboard", "starter",
          "lazy", "mason", "spectre_panel", "toggleterm", "aerial",
          "TelescopePrompt", "neo-tree", "Trouble", "trouble", "notify",
          "oil", "fugitive", "gitcommit"
        }
        
        -- Only open for normal buffers with code
        if buftype == "" 
          and filetype ~= "" 
          and not vim.tbl_contains(excluded_filetypes, filetype) 
          and vim.fn.filereadable(bufname) == 1 then
          
          -- Delay to ensure buffer is fully loaded
          vim.defer_fn(function()
            local ok, aerial = pcall(require, "aerial")
            if ok and vim.api.nvim_buf_is_valid(bufnr) then
              pcall(function()
                aerial.open({ focus = false })
              end)
            end
          end, 300)
        end
      end,
    })
  end,
}

