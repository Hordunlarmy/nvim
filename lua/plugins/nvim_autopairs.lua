return {
  "windwp/nvim-autopairs",

  config = function()
    require('nvim-autopairs').setup{}

    local Rule = require('nvim-autopairs.rule')
    local npairs = require('nvim-autopairs')
    npairs.add_rule(Rule("__", "__", "python"))
  end
}

