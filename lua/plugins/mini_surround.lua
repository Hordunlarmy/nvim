-- mini.surround: Add/delete/replace surroundings (brackets, quotes, etc.)
return {
  "echasnovski/mini.surround",
  version = false,
  event = "VeryLazy",
  opts = {
    mappings = {
      add = "gsa",            -- Add surrounding in Normal and Visual modes
      delete = "gsd",         -- Delete surrounding
      find = "gsf",           -- Find surrounding (to the right)
      find_left = "gsF",      -- Find surrounding (to the left)
      highlight = "gsh",      -- Highlight surrounding
      replace = "gsr",        -- Replace surrounding
      update_n_lines = "gsn", -- Update `n_lines`
    },
    n_lines = 20,
    respect_selection_type = false,
    search_method = "cover",
    silent = false,
  },
}


