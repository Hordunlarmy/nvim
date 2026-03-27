-- nvim-notify: Better notification manager

local function ensure_noice()
  local ok_noice, noice = pcall(require, "noice")
  if ok_noice then
    return true, noice
  end

  local ok_lazy, lazy = pcall(require, "lazy")
  if ok_lazy and type(lazy.load) == "function" then
    pcall(lazy.load, { plugins = { "noice.nvim" } })
    ok_noice, noice = pcall(require, "noice")
    if ok_noice then
      return true, noice
    end
  end

  return false, nil
end

local function run_noice_cmd(cmd)
  local ok_noice, noice = ensure_noice()
  if ok_noice and type(noice.cmd) == "function" then
    if pcall(noice.cmd, cmd) then
      return true
    end
  end

  if vim.fn.exists(":Noice") == 2 then
    return pcall(vim.cmd, "Noice " .. cmd)
  end
  return false
end

local function dismiss_all_notifications()
  pcall(function()
    require("notify").dismiss({ silent = true, pending = true })
  end)
  run_noice_cmd("dismiss")

  local ok_ticker, ticker = pcall(require, "util.notify_ticker")
  if ok_ticker and type(ticker.clear) == "function" then
    pcall(ticker.clear)
  end
end

return {
  "rcarriga/nvim-notify",
  event = "VeryLazy",
  keys = {
    {
      "<leader>un",
      function()
        dismiss_all_notifications()
      end,
      desc = "Dismiss all Notifications",
    },
    {
      "<leader>uh",
      function()
        if not run_noice_cmd("history") then
          vim.notify("Noice history is unavailable", vim.log.levels.WARN)
        end
      end,
      desc = "Show message history (copyable split)",
    },
    {
      "<leader>uH",
      function()
        if not run_noice_cmd("last") then
          vim.notify("Noice last is unavailable", vim.log.levels.WARN)
        end
      end,
      desc = "Show last message (details)",
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
  end,
}
