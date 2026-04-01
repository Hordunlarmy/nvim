local config = function()
  local function apply_tree_highlights()
    local commands = {
      "highlight NvimTreeNormal guibg=NONE ctermbg=NONE",
      "highlight NvimTreeNormalNC guibg=NONE ctermbg=NONE",
      "highlight NvimTreeEndOfBuffer guibg=NONE ctermbg=NONE",
      "highlight NvimTreeWinSeparator guibg=NONE ctermbg=NONE",
      "highlight NvimTreeVertSplit guibg=NONE ctermbg=NONE",
      "highlight WinSeparator guifg=#8B8B8B guibg=NONE",
    }

    for _, cmd in ipairs(commands) do
      pcall(vim.cmd, cmd)
    end
  end

  _G.apply_nvim_tree_highlights = apply_tree_highlights

  local diagnostics_enabled = vim.g.diagnostics_global_enabled ~= false

  require("nvim-tree").setup({
    hijack_cursor = true,
    sync_root_with_cwd = true,
    view = {
      adaptive_size = false,
      width = 30,
      side = "left",
    },
    renderer = {
      full_name = true,
      group_empty = true,
      special_files = {},
      symlink_destination = false,
      indent_markers = {
        enable = true,
      },
      icons = {
        git_placement = "signcolumn",
        show = {
          file = true,
          folder = true,
          folder_arrow = false,
          git = true,
          diagnostics = diagnostics_enabled,
        },
      },
    },
    update_focused_file = {
      enable = true,
      -- Avoid cwd/root churn on every file switch.
      update_root = false,
      ignore_list = { "help" },
    },
    diagnostics = {
      enable = diagnostics_enabled,
      show_on_dirs = true,
    },
    git = {
      enable = true,
      ignore = false,
      timeout = 2000,
    },
    filters = {
      custom = {
        "^.git$",
      },
      git_ignored = false,
    },
    actions = {
      change_dir = {
        enable = false,
        restrict_above_cwd = true,
      },
      open_file = {
        -- Keep tree width stable; resizing here fights with other side panes.
        resize_window = false,
        window_picker = {
          chars = "aoeui",
        },
      },
      remove_file = {
        close_window = false,
      },
    },
    log = {
      enable = false,
      truncate = true,
      types = {
        all = false,
        config = false,
        copy_paste = false,
        diagnostics = false,
        git = true,
        profile = false,
        watcher = false,
      },
    },
  }) 

  -- Startup layout: always open tree + aerial on launch, then focus main window.
  vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("NvimStartupLayout", { clear = true }),
    once = true,
    callback = function()
      vim.defer_fn(function()
        local ok_tree, api = pcall(require, "nvim-tree.api")
        if ok_tree then
          pcall(api.tree.open)
        end

        local main_win = nil
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          if vim.api.nvim_win_is_valid(win) then
            local buf = vim.api.nvim_win_get_buf(win)
            local ft = vim.bo[buf].filetype
            if ft ~= "NvimTree" and ft ~= "aerial" then
              main_win = win
              break
            end
          end
        end

        if main_win and vim.api.nvim_win_is_valid(main_win) then
          pcall(vim.api.nvim_set_current_win, main_win)
        end

        pcall(vim.cmd, "silent! AerialOpen right")

        if main_win and vim.api.nvim_win_is_valid(main_win) then
          pcall(vim.api.nvim_set_current_win, main_win)
        end
      end, 80)
    end,
  })

  -- Set termguicolors to enable highlight groups
  vim.opt.termguicolors = true

  local tree_group = vim.api.nvim_create_augroup("NvimTreeHighlights", { clear = true })
  vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter", "User" }, {
    group = tree_group,
    pattern = { "*", "LazyDone" },
    callback = function()
      vim.defer_fn(apply_tree_highlights, 30)
    end,
  })

  apply_tree_highlights()
end

return {
  "nvim-tree/nvim-tree.lua",
  lazy = false,
  config = config,
}
