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
  },
  opts = {
    timeout = 3000,
    max_height = function()
      return math.floor(vim.o.lines * 0.75)
    end,
    max_width = function()
      return math.floor(vim.o.columns * 0.75)
    end,
    on_open = function(win)
      vim.api.nvim_win_set_config(win, { zindex = 100 })
      vim.api.nvim_win_set_option(win, 'winblend', 0)  -- Opaque
    end,
    background_colour = "#000000",  -- Default background for transparency calculations
    fps = 30,
    icons = {
      DEBUG = "",
      ERROR = "",
      INFO = "",
      TRACE = "✎",
      WARN = "",
    },
    level = 2,
    minimum_width = 50,
    render = "default",
    stages = "fade_in_slide_out",
    minimum_width = 50,
    time_formats = {
      notification = "%T",
      notification_history = "%FT%T",
    },
    top_down = true,
  },
  init = function()
    vim.notify = require("notify")
  end,
}

