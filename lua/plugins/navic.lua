return {
  "SmiteshP/nvim-navic",
  event = "LspAttach",
  opts = {
    highlight = true,
    separator = " > ",
    depth_limit = 5,
    safe_output = true,
    lsp = {
      auto_attach = false,
    },
  },
}
