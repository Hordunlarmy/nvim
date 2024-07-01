-- transparency support in neovim (for adding background image, etc.)

return {
  "xiyaowong/transparent.nvim",
  config = function()
    require("transparent").setup({
      enable = true,  -- Enable transparent windows
      extra_groups = { -- Additional groups to make transparent
        "Normal",
        "NormalFloat",
        "NormalNC",
      },
      exclude = {},    -- Exclude specific groups from becoming transparent
    })
  end,
}

