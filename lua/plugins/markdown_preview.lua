return {
  "iamcco/markdown-preview.nvim",
  build = function()
    vim.fn["mkdp#util#install"]()
  end,

  config = function()
    vim.g.mkdp_auto_start = 1      -- Automatically open preview on markdown file open
    vim.g.mkdp_auto_close = 1      -- Automatically close preview when the markdown file is closed
    vim.g.mkdp_refresh_slow = 0    -- Disable slow refresh mode, recommended in some cases
    vim.g.mkdp_preview_options = {
      mkit = {},                   -- Use `markdown-it` for parsing markdown, if installed
      katex = {},                  -- Enable KaTeX for math support
      uml = {},                    -- Enable markdown-preview.nvim's built-in mermaid and viz.js support
      disable_sync_scroll = 0,     -- Sync scroll is enabled by default
      hide_yaml_meta = 1,          -- Hide yaml meta in preview
      sequence_diagrams = {},      -- Enable sequence diagrams support
      flowchart_diagrams = {}      -- Enable flowchart diagrams support
    }
  end,
}
