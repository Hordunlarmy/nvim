local AERIAL_PANEL_WIDTH = 32

local handoff = {
  tab_state = {},
}

local function tab_valid(tab)
  return tab and vim.api.nvim_tabpage_is_valid(tab)
end

local function find_panel_win(tab, ft)
  if not tab_valid(tab) then
    return nil
  end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == ft then
      return win
    end
  end
  return nil
end

local function has_sidekick_win(tab)
  return find_panel_win(tab, "sidekick_terminal") ~= nil
end

local function set_tab_flag(tab, value)
  if not tab_valid(tab) then
    return
  end
  pcall(vim.api.nvim_tabpage_set_var, tab, "sidekick_active", value)
end

local function get_tab_state(tab)
  local state = handoff.tab_state[tab]
  if not state then
    state = {
      width = AERIAL_PANEL_WIDTH,
    }
    handoff.tab_state[tab] = state
  end
  return state
end

local function replace_aerial_with_sidekick(tab)
  local state = get_tab_state(tab)
  local aer_win = find_panel_win(tab, "aerial")
  set_tab_flag(tab, true)

  if aer_win then
    local width = vim.api.nvim_win_get_width(aer_win)
    if width and width > 0 then
      state.width = width
    end
    local ok_close = pcall(vim.api.nvim_win_close, aer_win, true)
    if not ok_close then
      local ok_aerial, aerial = pcall(require, "aerial")
      if ok_aerial then
        pcall(aerial.close)
      end
    end
  end

  return state
end

local function mark_sidekick_inactive(tab)
  if not tab_valid(tab) then
    handoff.tab_state[tab] = nil
    return
  end
  if has_sidekick_win(tab) then
    return
  end

  set_tab_flag(tab, false)
end

local function refresh_all_tabs()
  for tab, _ in pairs(handoff.tab_state) do
    mark_sidekick_inactive(tab)
  end
end

local function prepare_sidekick_panel(terminal)
  if terminal.opts.layout == "float" then
    return
  end
  local tab = vim.api.nvim_get_current_tabpage()
  local state = replace_aerial_with_sidekick(tab)

  terminal.opts.layout = "right"
  terminal.opts.split = vim.tbl_deep_extend("force", terminal.opts.split or {}, {
    width = state.width or AERIAL_PANEL_WIDTH,
    height = 0,
  })
end

local function sidekick_float_config_for_current_win()
  local anchor = vim.api.nvim_get_current_win()
  if not anchor or not vim.api.nvim_win_is_valid(anchor) then
    return nil
  end
  local width = vim.api.nvim_win_get_width(anchor)
  local height = vim.api.nvim_win_get_height(anchor)
  local float_w = math.max(80, math.floor(width * 0.9))
  local float_h = math.max(10, math.floor(height * 0.85))
  local row = math.max(0, math.floor((height - float_h) / 2))
  local col = math.max(0, math.floor((width - float_w) / 2))
  return {
    relative = "win",
    win = anchor,
    width = float_w,
    height = float_h,
    row = row,
    col = col,
    border = "rounded",
    style = "minimal",
    title = " Sidekick ",
    title_pos = "center",
  }
end

local function apply_sidekick_layout(layout, layout_opts)
  local ok_config, config = pcall(require, "sidekick.config")
  if not ok_config or not config.cli or not config.cli.win then
    return false
  end

  config.cli.win.layout = layout
  if layout == "float" then
    config.cli.win.float = vim.tbl_deep_extend("force", config.cli.win.float or {}, layout_opts or {})
  else
    config.cli.win.split = vim.tbl_deep_extend("force", config.cli.win.split or {}, layout_opts or {})
  end

  local ok_state, state = pcall(require, "sidekick.cli.state")
  if ok_state then
    local attached = state.get({ attached = true, terminal = true })
    for _, item in ipairs(attached) do
      local terminal = item.terminal
      if terminal then
        terminal.opts.layout = layout
        if layout == "float" then
          terminal.opts.float = vim.tbl_deep_extend("force", terminal.opts.float or {}, layout_opts or {})
        else
          terminal.opts.split = vim.tbl_deep_extend("force", terminal.opts.split or {}, layout_opts or {})
        end
      end
    end
  end

  return true
end

local function sidekick_attached_in_cwd_exists()
  local ok_state, state = pcall(require, "sidekick.cli.state")
  if not ok_state then
    return false
  end
  local items = state.get({ attached = true, terminal = true, cwd = true })
  return type(items) == "table" and #items > 0
end

local function sidekick_opts_for_current_context(opts)
  opts = vim.tbl_deep_extend("force", {}, opts or {})
  if sidekick_attached_in_cwd_exists() then
    opts.filter = vim.tbl_deep_extend("force", {}, opts.filter or {}, { cwd = true, attached = true })
  else
    opts.filter = nil
  end
  return opts
end

return {
  "folke/sidekick.nvim",
  event = "VeryLazy",
  opts = {
    cli = {
      win = {
        layout = "right",
        split = {
          width = AERIAL_PANEL_WIDTH,
          height = 0,
        },
        keys = {
          stopinsert_esc = {
            "<Esc>",
            "stopinsert",
            mode = "t",
            desc = "Sidekick: terminal -> normal mode",
          },
        },
        config = prepare_sidekick_panel,
      },
    },
  },
  keys = {
    {
      "<c-.>",
      function()
        require("sidekick.cli").focus()
      end,
      mode = { "n", "t", "i", "x" },
      desc = "Sidekick focus",
    },
    {
      "<leader>kk",
      function()
        local tab = vim.api.nvim_get_current_tabpage()
        replace_aerial_with_sidekick(tab)
        require("sidekick.cli").toggle(sidekick_opts_for_current_context())
      end,
      desc = "Sidekick toggle CLI",
    },
    {
      "<leader>ks",
      function()
        require("sidekick.cli").select()
      end,
      desc = "Sidekick select tool",
    },
    {
      "<leader>kf",
      function()
        local float_opts = sidekick_float_config_for_current_win()
        if not float_opts then
          vim.notify("Could not resolve current window for Sidekick float", vim.log.levels.WARN)
          return
        end
        if not apply_sidekick_layout("float", float_opts) then
          vim.notify("Could not configure Sidekick floating mode", vim.log.levels.WARN)
          return
        end
        require("sidekick.cli").show(sidekick_opts_for_current_context({ focus = true }))
      end,
      desc = "Sidekick float popup (relative to win)",
    },
    {
      "<leader>kF",
      function()
        local tab = vim.api.nvim_get_current_tabpage()
        local state = replace_aerial_with_sidekick(tab)
        local split_opts = {
          width = (state and state.width) or AERIAL_PANEL_WIDTH,
          height = 0,
        }
        if not apply_sidekick_layout("right", split_opts) then
          vim.notify("Could not configure Sidekick split mode", vim.log.levels.WARN)
          return
        end
        require("sidekick.cli").show(sidekick_opts_for_current_context({ focus = true }))
      end,
      desc = "Sidekick focus split panel",
    },
    {
      "<leader>kd",
      function()
        require("sidekick.cli").close()
      end,
      desc = "Sidekick detach session",
    },
    {
      "<leader>kp",
      function()
        require("sidekick.cli").prompt()
      end,
      mode = { "n", "x" },
      desc = "Sidekick prompt",
    },
    {
      "<leader>kt",
      function()
        require("sidekick.cli").send({ msg = "{this}" })
      end,
      mode = { "n", "x" },
      desc = "Sidekick send this",
    },
    {
      "<leader>kv",
      function()
        require("sidekick.cli").send({ msg = "{selection}" })
      end,
      mode = { "x" },
      desc = "Sidekick send selection",
    },
    {
      "<leader>kn",
      function()
        require("sidekick").nes_jump_or_apply()
      end,
      desc = "Sidekick next/apply edit",
    },
    {
      "<leader>ku",
      function()
        require("sidekick.nes").update()
      end,
      desc = "Sidekick update edits",
    },
    {
      "<leader>ke",
      function()
        require("sidekick.nes").toggle()
      end,
      desc = "Sidekick toggle NES",
    },
  },
  config = function(_, opts)
    local ok, sidekick = pcall(require, "sidekick")
    if ok then
      sidekick.setup(opts)
    end

    local group = vim.api.nvim_create_augroup("SidekickAerialHandoff", { clear = true })

    vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter" }, {
      group = group,
      callback = function(args)
        local bufnr = args.buf
        if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
          return
        end
        if vim.bo[bufnr].filetype ~= "sidekick_terminal" then
          return
        end
        local win = vim.api.nvim_get_current_win()
        if not vim.api.nvim_win_is_valid(win) then
          return
        end
        local tab = vim.api.nvim_win_get_tabpage(win)
        set_tab_flag(tab, true)
        get_tab_state(tab)
      end,
    })

    vim.api.nvim_create_autocmd("WinClosed", {
      group = group,
      callback = function()
        vim.schedule(function()
          refresh_all_tabs()
        end)
      end,
    })

    vim.api.nvim_create_autocmd("TabClosed", {
      group = group,
      callback = function()
        for tab, _ in pairs(handoff.tab_state) do
          if not tab_valid(tab) then
            handoff.tab_state[tab] = nil
          end
        end
      end,
    })
  end,
}
