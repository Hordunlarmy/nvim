-- nvim-notify: Better notification manager

local function ensure_noice()
  local ok_noice, noice = pcall(require, "noice")
  if ok_noice then
    return true, noice
  end

  local ok_lazy, lazy = pcall(require, "lazy")
  if ok_lazy and type(lazy.load) == "function" then
    -- Try both canonical and short names for compatibility with lazy plugin ids.
    pcall(lazy.load, { plugins = { "folke/noice.nvim", "noice.nvim" } })
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

  -- Fallback for newer noice versions where commands may not be ready yet.
  if ok_noice and (cmd == "history" or cmd == "last") then
    local ok_manager, manager = pcall(require, "noice.message.manager")
    local ok_view, view_mod = pcall(require, "noice.view")
    if ok_manager and ok_view then
      local view_name = cmd == "history" and "history_win" or "popup"
      local opts = { enter = true, format = "details" }
      local ok_view_obj, view = pcall(view_mod.get_view, view_name, opts)
      if ok_view_obj and view then
        local filter = {
          any = {
            { event = "notify" },
            { error = true },
            { warning = true },
            { event = "msg_show", kind = { "" } },
            { event = "lsp", kind = "message" },
          },
        }
        local filter_opts = { history = true, sort = true }
        if cmd == "last" then
          filter_opts.count = 1
        end
        local ok_get, messages = pcall(manager.get, filter, filter_opts)
        if ok_get then
          local ok_set = pcall(function()
            view:set(messages)
            view:display()
          end)
          if ok_set then
            return true
          end
        end
      end
    end
  end

  if vim.fn.exists(":Noice") == 2 then
    if pcall(vim.cmd, "Noice " .. cmd) then
      return true
    end
    return pcall(vim.cmd, "Noice")
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
  lazy = false,
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
        local ok_ticker, ticker = pcall(require, "util.notify_ticker")
        if ok_ticker and type(ticker.show_history) == "function" then
          if pcall(ticker.show_history, {}) then
            return
          end
        end
        vim.notify("Ticker history is unavailable", vim.log.levels.WARN)
      end,
      desc = "Show message history (popup)",
    },
    {
      "<leader>uH",
      function()
        local ok_ticker, ticker = pcall(require, "util.notify_ticker")
        if ok_ticker and type(ticker.show_history) == "function" then
          if pcall(ticker.show_history, { last = true }) then
            return
          end
        end
        vim.notify("Ticker history is unavailable", vim.log.levels.WARN)
      end,
      desc = "Show last message (details)",
    },
  },
  opts = {
    timeout = 7000,
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

    local routed_vim_notify = vim.notify
    local function route_to_statusline(msg, level, notify_opts)
      if type(routed_vim_notify) == "function" then
        routed_vim_notify(msg, level, notify_opts)
      end
      return { id = math.floor(vim.uv.hrtime() / 1e6) }
    end

    notify.notify = route_to_statusline
    local mt = getmetatable(notify)
    if mt then
      mt.__call = function(_, msg, level, notify_opts)
        if vim.in_fast_event() then
          vim.schedule(function()
            route_to_statusline(msg, level, notify_opts)
          end)
          return { id = math.floor(vim.uv.hrtime() / 1e6) }
        end
        return route_to_statusline(msg, level, notify_opts)
      end
    end
  end,
}
