-- bufferline: Enhanced buffer/tab line
return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "famiu/bufdelete.nvim",
  },
  event = "VeryLazy",
  keys = {
    { "<Tab>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
    { "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
    { "<leader>bp", "<cmd>BufferLinePick<cr>", desc = "Pick buffer" },
    { "<leader>bc", "<cmd>BufferLinePickClose<cr>", desc = "Pick close buffer" },
    { "<leader>bl", "<cmd>BufferLineCloseRight<cr>", desc = "Close all to the right" },
    { "<leader>bh", "<cmd>BufferLineCloseLeft<cr>", desc = "Close all to the left" },
  },
  config = function()
    require("bufferline").setup({
      options = {
        mode = "buffers",
        numbers = "none",
        close_command = function(bufnum)
          -- Only close the buffer, don't quit Neovim
          require("bufdelete").bufdelete(bufnum, false)
        end,
        right_mouse_command = function(bufnum)
          require("bufdelete").bufdelete(bufnum, false)
        end,
        left_mouse_command = "buffer %d",
        middle_mouse_command = nil,
        indicator = {
          icon = "▎",
          style = "icon",
        },
        buffer_close_icon = "✕",  -- Close X button
        modified_icon = "●",
        close_icon = "✕",
        left_trunc_marker = "",
        right_trunc_marker = "",
        max_name_length = 18,
        max_prefix_length = 15,
        truncate_names = true,
        tab_size = 20,
        diagnostics = "nvim_lsp",
        diagnostics_update_in_insert = false,
        diagnostics_indicator = function(count, level, diagnostics_dict, context)
          local icon = level:match("error") and " " or " "
          return " " .. icon .. count
        end,
        offsets = {
          {
            filetype = "NvimTree",
            text = "File Explorer",
            text_align = "center",
            separator = true,
          },
          {
            filetype = "aerial",
            text = "Code Outline",
            text_align = "center",
            separator = true,
          },
        },
        color_icons = true,
        get_element_icon = function(element)
          local icon, hl = require('nvim-web-devicons').get_icon_by_filetype(element.filetype, { default = false })
          return icon, hl
        end,
        show_buffer_icons = true,
        show_buffer_close_icons = true,  -- Show close button on each buffer
        show_close_icon = true,  -- Show close icon on right side
        show_tab_indicators = true,
        show_duplicate_prefix = true,
        persist_buffer_sort = true,
        separator_style = "thin",
        enforce_regular_tabs = false,
        always_show_bufferline = true,
        hover = {
          enabled = true,
          delay = 200,
          reveal = {},  -- Don't hide close button - always show it
        },
        sort_by = "insert_after_current",
        themable = true,  -- Allow theme integration
      },
    })
    
    -- Force all bufferline backgrounds to be completely transparent
    vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
      callback = function()
        vim.defer_fn(function()
          -- Get Normal background (will be NONE if transparent)
          local normal_bg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Normal")), "bg")
          if normal_bg == "" then
            normal_bg = "NONE"
          end
          
          vim.cmd("highlight! BufferLineFill guibg=" .. normal_bg)
          vim.cmd("highlight! BufferLineBackground guibg=" .. normal_bg)
          vim.cmd("highlight! BufferLineBufferSelected guibg=" .. normal_bg .. " gui=bold")
          vim.cmd("highlight! BufferLineBufferVisible guibg=" .. normal_bg)
          vim.cmd("highlight! BufferLineSeparator guibg=" .. normal_bg .. " guifg=" .. normal_bg)
          vim.cmd("highlight! BufferLineSeparatorSelected guibg=" .. normal_bg)
          vim.cmd("highlight! BufferLineSeparatorVisible guibg=" .. normal_bg)
          vim.cmd("highlight! BufferLineTab guibg=" .. normal_bg)
          vim.cmd("highlight! BufferLineTabSelected guibg=" .. normal_bg .. " gui=bold")
          vim.cmd("highlight! BufferLineTabClose guibg=" .. normal_bg)
          -- Close buttons always visible
          vim.cmd("highlight! BufferLineCloseButton guifg=#888888 guibg=" .. normal_bg)  -- Gray X
          vim.cmd("highlight! BufferLineCloseButtonVisible guifg=#888888 guibg=" .. normal_bg)  -- Gray X
          vim.cmd("highlight! BufferLineCloseButtonSelected guifg=#ff5555 guibg=" .. normal_bg)  -- Red X on selected
          vim.cmd("highlight! BufferLineModified guibg=" .. normal_bg)
          vim.cmd("highlight! BufferLineModifiedVisible guibg=" .. normal_bg)
          vim.cmd("highlight! BufferLineModifiedSelected guibg=" .. normal_bg)
        end, 100)
      end,
    })
  end,
}

