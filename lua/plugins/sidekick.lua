local PANEL_WIDTH = 32

local function find_win_by_ft(ft)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == ft then
      return win
    end
  end
  return nil
end

local function sidekick_win_open()
  return find_win_by_ft("sidekick_terminal") ~= nil
end

local function close_aerial_and_capture_width()
  local aer_win = find_win_by_ft("aerial")
  if not aer_win then
    return PANEL_WIDTH
  end
  local width = vim.api.nvim_win_get_width(aer_win)
  local ok_aerial, aerial = pcall(require, "aerial")
  if ok_aerial then
    pcall(aerial.close)
  else
    pcall(vim.api.nvim_win_close, aer_win, true)
  end
  return (width and width > 0) and width or PANEL_WIDTH
end

local function set_sidekick_right_width(width)
  local ok_cfg, cfg = pcall(require, "sidekick.config")
  if not ok_cfg or not cfg.cli or not cfg.cli.win then
    return
  end
  cfg.cli.win.layout = "right"
  cfg.cli.win.split = vim.tbl_deep_extend("force", cfg.cli.win.split or {}, {
    width = width or PANEL_WIDTH,
    height = 0,
  })
end

return {
  "folke/sidekick.nvim",
  event = "VeryLazy",
  opts = {
    nes = {
      enabled = false,
    },
    cli = {
      win = {
        layout = "right",
        split = {
          width = PANEL_WIDTH,
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
        local cli = require("sidekick.cli")
        if sidekick_win_open() then
          cli.close()
          return
        end
        local width = close_aerial_and_capture_width()
        set_sidekick_right_width(width)
        cli.show({ focus = true })
      end,
      desc = "Sidekick toggle CLI",
    },
    {
      "<leader>kF",
      function()
        require("sidekick.cli").show({ focus = true })
      end,
      desc = "Sidekick focus split panel",
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
        require("sidekick.cli").show({
          focus = true,
          layout = "float",
          float = {
            width = 0.9,
            height = 0.85,
          },
        })
      end,
      desc = "Sidekick float popup (relative to win)",
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
      mode = "x",
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
    require("sidekick").setup(opts)
  end,
}
