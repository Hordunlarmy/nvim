-- transparency support in neovim (for adding background image, etc.)

return {
  "xiyaowong/transparent.nvim",
  lazy = false,
  priority = 1000,


  config = function()
    require("transparent").setup({
      extra_groups = { -- Additional groups to make transparent
        "Normal",
        "NormalFloat",
        "NormalNC",
      },
      exclude_groups = {}, -- Exclude specific groups from becoming transparent
    })
  end,
}
