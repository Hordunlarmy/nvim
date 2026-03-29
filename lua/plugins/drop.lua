return {
  "folke/drop.nvim",
  event = "VimEnter",
  config = function(_, opts)
    require("drop").setup(opts)
  end,
  opts = {
    -- Professional, non-emoji minimalist theme.
    theme = {
      symbols = { "·", "•", "⋅", ".", "˙" },
      colors = { "#5f6c7b", "#6f7f90", "#8595a6", "#9aa7b5" },
    },
    max = 55,
    interval = 120,
    screensaver = 1000 * 60 * 5,
    -- Empty list disables auto-show on startup dashboards; only screensaver/manual toggle remains.
    filetypes = {},
    winblend = 100,
  },
  keys = {
    {
      "<leader>uD",
      function()
        local ok_core, core = pcall(require, "drop.drop")
        if ok_core and core and core.timer then
          require("drop").hide()
        else
          require("drop").show()
        end
      end,
      desc = "Toggle Drop effect",
    },
  },
}
