-- Plugin for git signs in the gutter of the buffer

return {
  "lewis6991/gitsigns.nvim",
  lazy = false,
  config = function()
    require("gitsigns").setup({
      signs = {
        add = { text = "│" },
        change = { text = "│" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        
        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end
        
        -- Navigation
        map('n', ']h', function()
          if vim.wo.diff then return ']c' end
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, { expr = true, desc = "Next git hunk" })

        map('n', '[h', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, { expr = true, desc = "Previous git hunk" })

        -- Actions (using <leader>g prefix for git)
        map('n', '<leader>gs', gs.stage_hunk, { desc = "Git stage hunk" })
        map('n', '<leader>gr', gs.reset_hunk, { desc = "Git reset hunk" })
        map('v', '<leader>gs', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = "Git stage hunk" })
        map('v', '<leader>gr', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = "Git reset hunk" })
        map('n', '<leader>gsa', gs.stage_buffer, { desc = "Git stage all (buffer)" })
        map('n', '<leader>gu', gs.undo_stage_hunk, { desc = "Git undo stage" })
        map('n', '<leader>gra', gs.reset_buffer, { desc = "Git reset all (buffer)" })
        map('n', '<leader>gp', gs.preview_hunk, { desc = "Git preview hunk" })
        map('n', '<leader>gb', function() gs.blame_line{full=true} end, { desc = "Git blame line" })
        map('n', '<leader>gt', gs.diffthis, { desc = "Git diff this" })
        map('n', '<leader>gT', function() gs.diffthis('~') end, { desc = "Git diff this ~" })
        
        -- Toggle
        map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = "Toggle git blame" })
        map('n', '<leader>tg', gs.toggle_deleted, { desc = "Toggle git deleted" })
      end
    })
  end
}
