-- persistence.nvim: restore files without restoring stale editor splits.
return {
  "folke/persistence.nvim",
  lazy = false,
  priority = 100,
  opts = {
    dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"),
  },
  config = function(_, opts)
    require("persistence").setup(opts)

    local function is_file_buffer(bufnr)
      return bufnr
        and vim.api.nvim_buf_is_valid(bufnr)
        and vim.bo[bufnr].buftype == ""
        and vim.api.nvim_buf_get_name(bufnr) ~= ""
    end

    local function is_editor_buffer(bufnr)
      return bufnr
        and vim.api.nvim_buf_is_valid(bufnr)
        and vim.bo[bufnr].buftype == ""
        and vim.bo[bufnr].filetype ~= "NvimTree"
        and vim.bo[bufnr].filetype ~= "aerial"
    end

    local function first_file_buffer()
      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if is_file_buffer(bufnr) and vim.bo[bufnr].buflisted then
          return bufnr
        end
      end
    end

    -- Session files contain window layout as well as buffers. We retain the
    -- buffers, but close only extra normal editor windows afterwards. Tree and
    -- Aerial are never closed here: they manage async state internally.
    _G.restore_session_with_plugins = function(load_opts)
      require("persistence").load(load_opts or {})

      vim.defer_fn(function()
        local target_win
        local target_buf
        local current_win = vim.api.nvim_get_current_win()
        if vim.api.nvim_win_is_valid(current_win) and is_file_buffer(vim.api.nvim_win_get_buf(current_win)) then
          target_win = current_win
          target_buf = vim.api.nvim_win_get_buf(current_win)
        end

        if not target_win then
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if is_file_buffer(vim.api.nvim_win_get_buf(win)) then
              target_win = win
              target_buf = vim.api.nvim_win_get_buf(win)
              break
            end
          end
        end

        target_buf = target_buf or first_file_buffer()
        if not target_win then
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if is_editor_buffer(vim.api.nvim_win_get_buf(win)) then
              target_win = win
              break
            end
          end
        end

        if not target_win or not target_buf or not vim.api.nvim_win_is_valid(target_win) then
          return
        end

        -- Ensure the one retained editor window actually displays a restored file.
        vim.api.nvim_win_set_buf(target_win, target_buf)
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          if win ~= target_win and vim.api.nvim_win_is_valid(win) and is_editor_buffer(vim.api.nvim_win_get_buf(win)) then
            pcall(vim.api.nvim_win_close, win, false)
          end
        end
        if vim.api.nvim_win_is_valid(target_win) then
          vim.api.nvim_set_current_win(target_win)
        end
        -- Reopen the tree without closing/recreating any Aerial buffers.
        local ok, tree = pcall(require, "nvim-tree.api")
        if ok then
          pcall(tree.tree.open)
          if vim.api.nvim_win_is_valid(target_win) then
            vim.api.nvim_set_current_win(target_win)
          end
        end
      end, 500)
    end
  end,
  keys = {
    { "<leader>qs", function() _G.restore_session_with_plugins() end, desc = "Restore Session" },
    { "<leader>ql", function() _G.restore_session_with_plugins({ last = true }) end, desc = "Restore Last Session" },
    {
      "<leader>qw",
      function()
        require("persistence").save()
        vim.notify("Session saved!", vim.log.levels.INFO, { timeout = 1000 })
      end,
      desc = "Save Session (manual)",
    },
    { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
  },
}
