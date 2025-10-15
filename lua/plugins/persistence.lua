-- persistence.nvim: Session management
return {
  "folke/persistence.nvim",
  lazy = false,  -- Load immediately to ensure function is available
  priority = 100,  -- Load early
  opts = {
    dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"),
    options = { "buffers", "curdir", "tabpages", "winsize", "folds" },
  },
  config = function(_, opts)
    require("persistence").setup(opts)
    
    -- Custom session restore function that reopens nvim-tree and aerial
    _G.restore_session_with_plugins = function()
      -- Load the session
      require("persistence").load()
      
      -- Small delay to let session load properly
      vim.defer_fn(function()
        -- Step 1: Close all nvim-tree and aerial windows (they might be in wrong positions)
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.api.nvim_buf_is_valid(buf) then
            local ft = vim.api.nvim_buf_get_option(buf, "filetype")
            if ft == "NvimTree" or ft == "aerial" then
              pcall(vim.api.nvim_win_close, win, true)
            end
          end
        end
        
        -- Step 2: Close empty unnamed buffers created during restore
        local buffers = vim.api.nvim_list_bufs()
        for _, buf in ipairs(buffers) do
          if vim.api.nvim_buf_is_valid(buf) then
            local name = vim.api.nvim_buf_get_name(buf)
            local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
            local modified = vim.api.nvim_buf_get_option(buf, "modified")
            -- Delete empty unnamed buffers
            if name == "" and buftype == "" and not modified then
              pcall(vim.api.nvim_buf_delete, buf, { force = false })
            end
          end
        end
        
        -- Step 3: Find if we have normal files to work with
        local has_files = false
        local first_normal_buf = nil
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_option(buf, "buflisted") then
            local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
            local name = vim.api.nvim_buf_get_name(buf)
            local ft = vim.api.nvim_buf_get_option(buf, "filetype")
            if buftype == "" and name ~= "" and ft ~= "NvimTree" and ft ~= "aerial" then
              has_files = true
              if not first_normal_buf then
                first_normal_buf = buf
              end
            end
          end
        end
        
        if has_files and first_normal_buf then
          -- Step 4: Focus on the first normal buffer
          vim.cmd("buffer " .. first_normal_buf)
          
          -- Step 5: Open nvim-tree on the LEFT
          vim.defer_fn(function()
            local nvim_tree_ok, nvim_tree_api = pcall(require, "nvim-tree.api")
            if nvim_tree_ok then
              nvim_tree_api.tree.open()
              
              -- Step 6: Focus back to the main buffer
              vim.defer_fn(function()
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                  local buf = vim.api.nvim_win_get_buf(win)
                  local ft = vim.api.nvim_buf_get_option(buf, "filetype")
                  if ft ~= "NvimTree" and ft ~= "aerial" and ft ~= "" then
                    vim.api.nvim_set_current_win(win)
                    break
                  end
                end
                
                -- Step 7: Open Aerial on the RIGHT (if viewing code)
                vim.defer_fn(function()
                  local aerial_ok = pcall(require, "aerial")
                  if aerial_ok then
                    local buf = vim.api.nvim_get_current_buf()
                    local ft = vim.api.nvim_buf_get_option(buf, "filetype")
                    local code_filetypes = {"lua", "python", "javascript", "typescript", "go", "rust", "c", "cpp", "java"}
                    if vim.tbl_contains(code_filetypes, ft) then
                      vim.cmd("AerialOpen right")
                      
                      -- Step 8: Final focus on main buffer
                      vim.defer_fn(function()
                        for _, win in ipairs(vim.api.nvim_list_wins()) do
                          local buf = vim.api.nvim_win_get_buf(win)
                          local ft = vim.api.nvim_buf_get_option(buf, "filetype")
                          if ft ~= "NvimTree" and ft ~= "aerial" and ft ~= "" then
                            vim.api.nvim_set_current_win(win)
                            break
                          end
                        end
                      end, 50)
                    end
                  end
                end, 100)
              end, 100)
            end
          end, 50)
        end
      end, 50)
    end
  end,
  keys = {
    {
      "<leader>qs",
      function()
        _G.restore_session_with_plugins()
      end,
      desc = "Restore Session",
    },
    {
      "<leader>ql",
      function()
        require("persistence").load({ last = true })
        vim.defer_fn(function()
          _G.restore_session_with_plugins()
        end, 100)
      end,
      desc = "Restore Last Session",
    },
    {
      "<leader>qw",
      function()
        require("persistence").save()
        vim.notify("Session saved!", vim.log.levels.INFO, { timeout = 1000 })
      end,
      desc = "Save Session (manual)",
    },
    {
      "<leader>qd",
      function()
        require("persistence").stop()
      end,
      desc = "Don't Save Current Session",
    },
  },
}


