-- nvim-notify: Better notification manager
return {
  "rcarriga/nvim-notify",
  event = "VeryLazy",
  keys = {
    {
      "<leader>un",
      function()
        pcall(function()
          require("notify").dismiss({ silent = true, pending = true })
        end)
        pcall(vim.cmd, "Noice dismiss")
        pcall(vim.cmd, "NoiceDismiss")
      end,
      desc = "Dismiss all Notifications",
    },
    {
      "<leader>uh",
      function()
        local ok_telescope, telescope = pcall(require, "telescope")
        if ok_telescope then
          pcall(telescope.load_extension, "notify")
          local ok_notify_picker = pcall(function()
            telescope.extensions.notify.notify({
              layout_strategy = "vertical",
              layout_config = { width = 0.8, height = 0.8 },
            })
          end)
          if ok_notify_picker then
            return
          end
        end
        pcall(vim.cmd, "Noice history")
      end,
      desc = "Show notification history (scrollable)",
    },
  },
  opts = {
    timeout = 2500,
    max_height = function()
      return 12
    end,
    max_width = function()
      return 60
    end,
    render = "wrapped-compact",
    stages = "fade",
    top_down = false,
    fps = 60,
    background_colour = "#000000",
    minimum_width = 32,
    on_open = function(win)
      vim.api.nvim_win_set_config(win, { zindex = 120 })
      vim.wo[win].winblend = 0
      vim.wo[win].wrap = true
      vim.wo[win].linebreak = true
      vim.wo[win].breakindent = true
    end,
    icons = {
      DEBUG = "",
      ERROR = "",
      INFO = "",
      TRACE = "",
      WARN = "",
    },
    level = 2,
    time_formats = {
      notification = "%T",
      notification_history = "%FT%T",
    },
  },
  config = function(_, opts)
    local notify = require("notify")
    notify.setup(opts)
    vim.notify = notify
  end,
}
