-- Plugin for git signs in the gutter of the buffer

return {
  "lewis6991/gitsigns.nvim",
  lazy = false,
  config = function()
    require("gitsigns").setup()
  end
}
