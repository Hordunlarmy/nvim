-- transparency support in neovim (for adding background image, etc.)

return {
  "xiyaowong/transparent.nvim",
  lazy = false,
  priority = 1000,


  config = function()
    require("transparent").setup({
      extra_groups = { -- Additional groups to make transparent
        "Normal",
        "NormalNC",
        -- Bufferline groups
        "BufferLineFill",
        "BufferLineBackground",
        "BufferLineSeparator",
        "BufferLineTab",
        -- REMOVED NormalFloat - we want OPAQUE floating windows!
      },
      exclude_groups = { -- EXCLUDE these from transparency
        "NormalFloat",
        "FloatBorder",
        "FloatTitle",
        "TelescopeBorder",
        "TelescopePromptBorder",
        "TelescopeResultsBorder",
        "TelescopePreviewBorder",
        "WhichKeyBorder",
        "LspInfoBorder",
      },
    })
  end,
}
