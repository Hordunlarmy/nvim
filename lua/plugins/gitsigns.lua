-- Plugin for git signs in the gutter of the buffer

return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local git_popup = require("util.git_popup")

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
        map('n', '<leader>gb', gs.blame, { desc = "Git blame buffer" })
        map('n', '<leader>gB', function() gs.blame_line { full = true } end, { desc = "Git blame line (popup)" })
        map('n', '<leader>gt', function() git_popup.show_unified_diff_popup({ bufnr = bufnr }) end, { desc = "Git diff this (popup)" })
        map('n', '<leader>gT', function() git_popup.show_unified_diff_popup({ bufnr = bufnr, rev = "~" }) end, { desc = "Git diff this ~ (popup)" })
        map('n', '<leader>dt', function() git_popup.show_unified_diff_popup({ bufnr = bufnr }) end, { desc = "Git diff popup (unified)" })
        
        -- Toggle
        map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = "Toggle git blame" })
        map('n', '<leader>tg', gs.toggle_deleted, { desc = "Toggle git deleted" })
      end
    })
  end
}
