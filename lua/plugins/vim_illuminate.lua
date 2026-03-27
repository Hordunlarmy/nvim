-- Plugin to highlight all instances of the word under the cursor

return {
  "RRethy/vim-illuminate",
  event = { "BufReadPost", "BufNewFile" },

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
