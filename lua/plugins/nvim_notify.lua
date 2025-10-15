-- nvim-notify: Better notification manager
return {
  "rcarriga/nvim-notify",
  keys = {
    {
      "<leader>un",
      function()
        require("notify").dismiss({ silent = true, pending = true })
      end,
      desc = "Dismiss all Notifications",
    },
    {
      "<leader>uh",
      function()
        -- Show notification history in a scrollable Telescope window
        require("telescope").extensions.notify.notify({
          layout_strategy = "vertical",
          layout_config = { width = 0.8, height = 0.8 },
        })
      end,
      desc = "Show notification history (scrollable)",
    },
  },
  opts = {
    timeout = 3000,
    
    -- Fixed max width and height
    max_height = function()
      return 15  -- Fixed at 15 lines
    end,
    max_width = function()
      return 32  -- Fixed at 32 characters
    end,
    
    on_open = function(win)
      vim.api.nvim_win_set_config(win, { zindex = 100 })
      vim.api.nvim_win_set_option(win, 'winblend', 0)  -- Opaque
      
      -- Enable word wrapping (not character wrapping!)
      vim.api.nvim_win_set_option(win, 'wrap', true)
      vim.api.nvim_win_set_option(win, 'linebreak', true)  -- Break at word boundaries
      vim.api.nvim_win_set_option(win, 'breakindent', false)
      vim.api.nvim_win_set_option(win, 'scrolloff', 0)
      
      -- Remove the @@@ symbols completely
      vim.wo[win].fillchars = 'eob: ,lastline: '  -- Hide @@@ and ~ symbols
      vim.wo[win].signcolumn = 'no'   -- No sign column
      
      -- Make notifications scrollable with j/k when focused
      vim.api.nvim_buf_set_keymap(vim.api.nvim_win_get_buf(win), 'n', 'j', '<C-e>', { noremap = true, silent = true })
      vim.api.nvim_buf_set_keymap(vim.api.nvim_win_get_buf(win), 'n', 'k', '<C-y>', { noremap = true, silent = true })
    end,
    
    background_colour = "#000000",
    fps = 30,
    icons = {
      DEBUG = "",
      ERROR = "",
      INFO = "",
      TRACE = "✎",
      WARN = "",
    },
    level = 2,
    minimum_width = 32,  -- 32 characters wide
    
    -- Custom render function for centered headers and word wrapping
    render = function(bufnr, notif, highlights, config)
      local namespace = vim.api.nvim_create_namespace("notify")
      local icon = notif.icon
      local title = notif.title[1]
      local message = notif.message
      
      -- Center the header (icon + title)
      local header = icon .. " " .. title
      local padding = math.floor((32 - #header) / 2)
      local centered_header = string.rep(" ", math.max(0, padding)) .. header
      
      -- Create separator line
      local separator = string.rep("─", 32)
      
      -- Build notification content
      local lines = { centered_header, separator, "" }  -- Header + separator + blank line
      
      -- Add message lines (word-wrapped automatically by Neovim)
      for _, msg_line in ipairs(message) do
        table.insert(lines, msg_line)
      end
      
      -- Set buffer content
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
      
      -- Apply highlights
      vim.api.nvim_buf_set_extmark(bufnr, namespace, 0, 0, {
        end_line = 0,
        hl_group = highlights.icon,
        end_col = #icon,
      })
      vim.api.nvim_buf_set_extmark(bufnr, namespace, 0, #icon + 1, {
        end_line = 0,
        hl_group = highlights.title,
        end_col = #centered_header,
      })
      -- Highlight the separator line
      vim.api.nvim_buf_set_extmark(bufnr, namespace, 1, 0, {
        end_line = 1,
        hl_group = highlights.border,
        end_col = #separator,
      })
      vim.api.nvim_buf_set_extmark(bufnr, namespace, 3, 0, {
        end_line = #lines - 1,
        hl_group = highlights.body,
        end_col = #lines[#lines],
      })
    end,
    
    stages = "fade_in_slide_out",
    
    time_formats = {
      notification = "%T",
      notification_history = "%FT%T",
    },
    
    -- BOTTOM-RIGHT positioning (bottom-up stacking)
    top_down = false,
  },
  init = function()
    vim.notify = require("notify")
  end,
}

