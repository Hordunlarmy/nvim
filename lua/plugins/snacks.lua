return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    -- Enable input header for better UI (replaces dressing.input)
    input = {
      enabled = true,
    },
    -- Enable picker for better selection UI (replaces dressing.select)
    picker = {
      enabled = true,
    },
    -- Optional: nice notifications
    notifier = {
      enabled = false,
    },
  },
}
