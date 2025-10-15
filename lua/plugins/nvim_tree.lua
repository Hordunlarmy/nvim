local config = function()
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
        },
      },
    },
    update_focused_file = {
      enable = true,
      update_root = true,
      ignore_list = { "help" },
    },
    diagnostics = {
      enable = true,
      show_on_dirs = true,
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
        resize_window = true,
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

  -- Move cursor to the other buffer
  vim.cmd([[autocmd VimEnter * wincmd p]])

  -- Set termguicolors to enable highlight groups
  vim.opt.termguicolors = true

  -- nvim-tree transparent background
  vim.cmd [[hi NvimTreeNormal guibg=NONE ctermbg=NONE]]

  -- Set window separator color
  vim.cmd([[highlight WinSeparator guifg=#8B8B8B guibg=NONE]])
end

return {
  "nvim-tree/nvim-tree.lua",
  lazy = false,
  config = config,
}
