-- Plugin to generate documentation comments for various programming languages

return {
  'kkoomen/vim-doge',
  build = ':call doge#install()',  -- Runs the doge installation
  config = function()
    -- Basic vim-doge configuration
    vim.g.doge_enable_mappings = 1    -- Enable default mappings
    vim.g.doge_doc_standard_python = 'google'  -- Set Python docstring style to Google

    -- Additional configurations
    vim.g.doge_mapping = '<Leader>d'  -- Set a custom mapping for documentation
    vim.g.doge_buffer_mappings = 0    -- Disable buffer-specific mappings
    vim.g.doge_comment_style = 'indent' -- Use indented comments
    vim.g.doge_template_file = ''     -- Path to a custom template file (if any)
  end,
}
