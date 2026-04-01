-- vim-sleuth: Automatically detect indentation
return {
  "tpope/vim-sleuth",
  event = { "BufReadPre", "BufNewFile" },
  init = function()
    -- Keep Clojure indentation deterministic (2-space convention).
    vim.g.sleuth_clojure_heuristics = 0
    vim.g.sleuth_edn_heuristics = 0
  end,
}

