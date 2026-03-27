-- Rainbow delimiters for parenthesis color

return {
  "hiphish/rainbow-delimiters.nvim",
  event = { "BufReadPost", "BufNewFile" },
  submodules = false,  -- Don't clone test submodules (fixes warning)
  config = function()
    -- Rainbow delimiters are automatically enabled
    -- Different colors for nested brackets/parentheses
    local rainbow_delimiters = require("rainbow-delimiters")
    
    vim.g.rainbow_delimiters = {
      strategy = {
        [''] = rainbow_delimiters.strategy['global'],
        vim = rainbow_delimiters.strategy['local'],
      },
      query = {
        [''] = 'rainbow-delimiters',
        lua = 'rainbow-blocks',
        clojure = 'rainbow-blocks',
      },
      highlight = {
        'RainbowDelimiterRed',
        'RainbowDelimiterYellow',
        'RainbowDelimiterBlue',
        'RainbowDelimiterOrange',
        'RainbowDelimiterGreen',
        'RainbowDelimiterViolet',
        'RainbowDelimiterCyan',
      },
    }
  end,
}
