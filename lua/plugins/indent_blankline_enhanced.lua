-- indent-blankline: Enhanced with scope highlighting
return {
  "lukas-reineke/indent-blankline.nvim",
  event = { "BufReadPost", "BufNewFile" },
  main = "ibl",
  config = function(_, opts)
    local hooks = require("ibl.hooks")
    hooks.register(hooks.type.SKIP_LINE, function(_, bufnr, _, line)
      local ft = vim.bo[bufnr].filetype
      if ft ~= "clojure" and ft ~= "cljc" and ft ~= "cljs" and ft ~= "edn" then
        return false
      end

      local leading_spaces = line:match("^( +)")
      if not leading_spaces then
        return false
      end

      local width = vim.bo[bufnr].shiftwidth
      if width <= 0 then
        width = vim.bo[bufnr].tabstop
      end
      if width <= 0 then
        width = 2
      end

      -- Skip indent guides on odd/partial indentation lines.
      return (#leading_spaces % width) ~= 0
    end)

    require("ibl").setup(opts)
  end,
  opts = {
    indent = {
      char = "│",
      tab_char = "│",
    },
    scope = {
      enabled = false,  -- Disable scope highlighting (no colored lines around functions)
      show_start = false,
      show_end = false,
    },
    exclude = {
      filetypes = {
        "help",
        "alpha",
        "dashboard",
        "neo-tree",
        "Trouble",
        "trouble",
        "lazy",
        "mason",
        "notify",
        "toggleterm",
        "lazyterm",
      },
    },
  },
}
