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
    -- bufferline reads this option while installing its hover handler.
    vim.o.mousemoveevent = true

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
        -- If session restore already has this buffer visible in a window,
        -- focus that window. Otherwise replace the current editor buffer.
        -- Neither path creates a split.
        left_mouse_command = function(bufnum)
          for _, win in ipairs(vim.fn.win_findbuf(bufnum)) do
            if vim.api.nvim_win_is_valid(win) then
              local win_buf = vim.api.nvim_win_get_buf(win)
              if vim.bo[win_buf].filetype ~= "NvimTree" and vim.bo[win_buf].filetype ~= "aerial" then
                vim.api.nvim_set_current_win(win)
                return
              end
            end
          end
          vim.api.nvim_set_current_buf(bufnum)
        end,
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
    
    -- Keep inactive tabs transparent, but give the current tab an obvious
    -- contrast so it remains easy to spot in a dense buffer list.
    local function apply_bufferline_highlights()
      local normal_bg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Normal")), "bg")
      if normal_bg == "" then normal_bg = "NONE" end

      local inactive = { bg = normal_bg, fg = "#94a3b8" }
      local visible = { bg = normal_bg, fg = "#cbd5e1" }
      local selected_bg = "#334155"
      local selected = { bg = selected_bg, fg = "#f8fafc", bold = true }

      vim.api.nvim_set_hl(0, "BufferLineFill", { bg = normal_bg })
      vim.api.nvim_set_hl(0, "BufferLineBackground", inactive)
      vim.api.nvim_set_hl(0, "BufferLineBufferVisible", visible)
      vim.api.nvim_set_hl(0, "BufferLineBufferSelected", selected)
      vim.api.nvim_set_hl(0, "BufferLineIndicatorSelected", { bg = selected_bg, fg = "#7dd3fc" })
      vim.api.nvim_set_hl(0, "BufferLineSeparator", { bg = normal_bg, fg = normal_bg })
      vim.api.nvim_set_hl(0, "BufferLineSeparatorVisible", { bg = normal_bg, fg = normal_bg })
      vim.api.nvim_set_hl(0, "BufferLineSeparatorSelected", { bg = selected_bg, fg = selected_bg })
      vim.api.nvim_set_hl(0, "BufferLineTab", inactive)
      vim.api.nvim_set_hl(0, "BufferLineTabSelected", selected)
      vim.api.nvim_set_hl(0, "BufferLineTabClose", { bg = normal_bg })
      vim.api.nvim_set_hl(0, "BufferLineCloseButton", { bg = normal_bg, fg = "#888888" })
      vim.api.nvim_set_hl(0, "BufferLineCloseButtonVisible", { bg = normal_bg, fg = "#aab4c4" })
      vim.api.nvim_set_hl(0, "BufferLineCloseButtonSelected", { bg = selected_bg, fg = "#f87171" })
      vim.api.nvim_set_hl(0, "BufferLineModified", inactive)
      vim.api.nvim_set_hl(0, "BufferLineModifiedVisible", visible)
      vim.api.nvim_set_hl(0, "BufferLineModifiedSelected", { bg = selected_bg, fg = "#fbbf24" })
    end

    local highlight_group = vim.api.nvim_create_augroup("BufferLineUserHighlights", { clear = true })
    vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
      group = highlight_group,
      callback = function() vim.schedule(apply_bufferline_highlights) end,
    })
    apply_bufferline_highlights()

    -- bufferline itself uses mouse hover only to reveal controls.  Add a small,
    -- non-focusable tooltip with the complete path of the hovered file tab.
    local tooltip_win
    local tooltip_path

    local function close_path_tooltip()
      if tooltip_win and vim.api.nvim_win_is_valid(tooltip_win) then
        vim.api.nvim_win_close(tooltip_win, true)
      end
      tooltip_win = nil
      tooltip_path = nil
    end

    local function show_path_tooltip()
      local hovered = require("bufferline.state").hovered
      local bufnr = hovered and tonumber(hovered.id)
      if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
        return close_path_tooltip()
      end

      local path = vim.api.nvim_buf_get_name(bufnr)
      if path == "" then path = "[No file name]" end
      if path == tooltip_path and tooltip_win and vim.api.nvim_win_is_valid(tooltip_win) then return end
      close_path_tooltip()

      local max_width = math.max(vim.o.columns - 4, 1)
      local width = math.min(math.max(vim.api.nvim_strwidth(path), math.min(30, max_width)), max_width)
      local tooltip_buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(tooltip_buf, 0, -1, false, { path })
      vim.bo[tooltip_buf].modifiable = false

      local mouse = vim.fn.getmousepos()
      tooltip_win = vim.api.nvim_open_win(tooltip_buf, false, {
        relative = "editor",
        row = 1,
        col = math.max(0, math.min(mouse.screencol - 1, vim.o.columns - width - 2)),
        width = width,
        height = 1,
        style = "minimal",
        border = "rounded",
        focusable = false,
        noautocmd = true,
        zindex = 80,
      })
      vim.wo[tooltip_win].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder"
      tooltip_path = path
    end

    local tooltip_group = vim.api.nvim_create_augroup("BufferLinePathTooltip", { clear = true })
    vim.api.nvim_create_autocmd("User", {
      group = tooltip_group,
      pattern = "BufferLineHoverOver",
      callback = show_path_tooltip,
    })
    vim.api.nvim_create_autocmd("User", {
      group = tooltip_group,
      pattern = "BufferLineHoverOut",
      callback = close_path_tooltip,
    })
    vim.api.nvim_create_autocmd("VimLeavePre", {
      group = tooltip_group,
      callback = close_path_tooltip,
    })
  end,
}
