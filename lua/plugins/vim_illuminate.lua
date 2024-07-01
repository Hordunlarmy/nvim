return {
  "RRethy/vim-illuminate",
  lazy = false,

  config = function()
    require('illuminate').configure({
      providers = {
        'lsp',
        'treesitter',
        'regex',
      },
      delay = 100,})
    end,
  }
