return {
  "numToStr/Comment.nvim",
  dependencies = {
    "JoosepAlviste/nvim-ts-context-commentstring",
  },
  config = function()
    -- Setup ts_context_commentstring first
    require('ts_context_commentstring').setup({
      enable_autocmd = false,
    })
    
    -- Setup Comment.nvim with ts integration
    require('Comment').setup({
      ---Add a space b/w comment and the line
      padding = true,
      ---Whether the cursor should stay at its position
      sticky = true,
      ---Lines to be ignored while (un)comment
      ignore = nil,
      ---LHS of toggle mappings in NORMAL mode
      toggler = {
        ---Line-comment toggle keymap
        line = 'gcc',
        ---Block-comment toggle keymap
        block = 'gbc',
      },
      ---LHS of operator-pending mappings in NORMAL and VISUAL mode
      opleader = {
        ---Line-comment keymap
        line = 'gc',
        ---Block-comment keymap
        block = 'gb',
      },
      ---Function to call before (un)comment
      pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
    })
    
    -- Set default commentstrings for common filetypes as fallback
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "*",
      callback = function()
        local ft = vim.bo.filetype
        if ft == "" then
          return
        end
        
        -- Set commentstring for various filetypes if not already set
        if vim.bo.commentstring == "" then
          local commentstrings = {
            lua = "-- %s",
            python = "# %s",
            javascript = "// %s",
            typescript = "// %s",
            go = "// %s",
            rust = "// %s",
            c = "// %s",
            cpp = "// %s",
            java = "// %s",
            vim = '" %s',
            bash = "# %s",
            sh = "# %s",
            zsh = "# %s",
            yaml = "# %s",
            toml = "# %s",
            markdown = "<!-- %s -->",
            html = "<!-- %s -->",
            css = "/* %s */",
            scss = "// %s",
            json = "",
            jsonc = "// %s",
          }
          
          if commentstrings[ft] then
            vim.bo.commentstring = commentstrings[ft]
          end
        end
      end,
    })
  end,
}
