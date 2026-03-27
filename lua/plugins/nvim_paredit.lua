-- nvim-paredit: Structural editing for S-expressions (Clojure, Lisp)

return {
  "julienvincent/nvim-paredit",
  ft = { "clojure", "edn" },
  config = function()
    local paredit = require("nvim-paredit")

    paredit.setup({
      use_default_keys = true,
      filetypes = { "clojure", "edn" },
      cursor = {
        enabled = true,
        mode = "auto",
      },
      indent = {
        enabled = true,
        indentor = require("nvim-paredit.indentation.native").indentor,
      },
      keys = {
        -- Slurp and barf
        [">)"] = { paredit.api.slurp_forwards, "Slurp forward" },
        ["<("] = { paredit.api.slurp_backwards, "Slurp backward" },
        ["<)"] = { paredit.api.barf_forwards, "Barf forward" },
        [">("] = { paredit.api.barf_backwards, "Barf backward" },

        -- Element motions
        [">e"] = { paredit.api.drag_element_forwards, "Drag element forward" },
        ["<e"] = { paredit.api.drag_element_backwards, "Drag element backward" },

        -- Form motions
        [">f"] = { paredit.api.drag_form_forwards, "Drag form forward" },
        ["<f"] = { paredit.api.drag_form_backwards, "Drag form backward" },

        -- Raise and splice
        ["<localleader>o"] = { paredit.api.raise_form, "Raise form" },
        ["<localleader>O"] = { paredit.api.raise_element, "Raise element" },

        -- Wrapping
        ["<localleader>w("] = {
          function() paredit.api.wrap_element_under_cursor("(", ")") end,
          "Wrap element with ()",
        },
        ["<localleader>w)"] = {
          function() paredit.api.wrap_element_under_cursor("(", ")") end,
          "Wrap element with ()",
        },
        ["<localleader>w["] = {
          function() paredit.api.wrap_element_under_cursor("[", "]") end,
          "Wrap element with []",
        },
        ["<localleader>w]"] = {
          function() paredit.api.wrap_element_under_cursor("[", "]") end,
          "Wrap element with []",
        },
        ["<localleader>w{"] = {
          function() paredit.api.wrap_element_under_cursor("{", "}") end,
          "Wrap element with {}",
        },
        ["<localleader>w}"] = {
          function() paredit.api.wrap_element_under_cursor("{", "}") end,
          "Wrap element with {}",
        },
      },
    })
  end,
}
