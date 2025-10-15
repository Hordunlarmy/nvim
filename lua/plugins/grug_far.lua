-- Grug-far: Modern search and replace (MUCH better than spectre!)
-- Simple, intuitive, and actually works!

return {
  "MagicDuck/grug-far.nvim",
  config = function()
    require("grug-far").setup({
      -- Open as split (we'll convert to float with autocmd)
      windowCreationCommand = "split",
      
      -- Use transient mode
      transient = true,
      
      -- Keybinds that make sense!
      keymaps = {
        replace = { n = "<leader>r" },  -- Just <leader>r to replace!
        qflist = { n = "<leader>q" },
        syncLocations = { n = "<leader>s" },
        syncLine = { n = "<leader>l" },
        close = { n = "q" },
        gotoLocation = { n = "<enter>" },
        pickHistoryEntry = { n = "<leader>p" },
      },
      
      -- Better icons
      icons = {
        enabled = true,
        searchInput = " ",
        replaceInput = " ",
        filesFilter = " ",
        flagsInput = "⚑ ",
        resultsStatusReady = "✓",
        resultsStatusError = "✗",
        resultsChangeIndicator = "┃",
        historyTitle = " ",
      },
      
      -- Better colors
      resultLocation = {
        showNumberLabel = true,
      },
    })
    
    -- Convert grug-far window to floating popup
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "grug-far",
      callback = function()
        -- Small delay to let the window initialize
        vim.defer_fn(function()
          local win = vim.api.nvim_get_current_win()
          
          -- Calculate centered position
          local width = math.floor(vim.o.columns * 0.9)
          local height = math.floor(vim.o.lines * 0.9)
          local row = math.floor((vim.o.lines - height) / 2)
          local col = math.floor((vim.o.columns - width) / 2)
          
          -- Convert to floating window
          vim.api.nvim_win_set_config(win, {
            relative = "editor",
            width = width,
            height = height,
            row = row,
            col = col,
            border = "rounded",
            style = "minimal",
            zindex = 50,
          })
          
          -- Set opaque
          vim.api.nvim_win_set_option(win, 'winblend', 0)
        end, 10)
      end,
    })
  end,
  keys = {
    {
      "<leader>sr",
      function()
        local grug = require("grug-far")
        local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
        grug.open({
          transient = true,
          prefills = {
            filesFilter = ext and ext ~= "" and "*." .. ext or nil,
          },
        })
      end,
      desc = "Search & Replace",
    },
    {
      "<leader>sw",
      function()
        local grug = require("grug-far")
        local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
        grug.open({
          transient = true,
          prefills = {
            search = vim.fn.expand("<cword>"),
            filesFilter = ext and ext ~= "" and "*." .. ext or nil,
          },
        })
      end,
      desc = "Search & Replace (word under cursor)",
    },
    {
      "<leader>sf",
      function()
        require("grug-far").open({
          transient = true,
          prefills = { paths = vim.fn.expand("%") },
        })
      end,
      desc = "Search & Replace (current file)",
    },
  },
}

