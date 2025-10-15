-- neoscroll: Smooth scrolling
return {
  "karb94/neoscroll.nvim",
  event = "VeryLazy",
  config = function()
    require("neoscroll").setup({
      mappings = {},  -- Disable default mappings
      hide_cursor = true,
      stop_eof = true,
      respect_scrolloff = false,
      cursor_scrolls_alone = true,
      easing_function = "sine",
      pre_hook = nil,
      post_hook = nil,
      performance_mode = false,
    })
    
    -- Custom keybindings (Ctrl-f is used for Telescope!)
    local neoscroll = require("neoscroll")
    local keymap = {
      ["<C-Up>"] = function() neoscroll.scroll(-vim.wo.scroll, { move_cursor = true, duration = 250 }) end,
      ["<C-Down>"] = function() neoscroll.scroll(vim.wo.scroll, { move_cursor = true, duration = 250 }) end,
      ["<C-b>"] = function() neoscroll.scroll(-vim.api.nvim_win_get_height(0), { move_cursor = true, duration = 450 }) end,
      -- <C-f> removed - used by Telescope live_grep
      ["<C-y>"] = function() neoscroll.scroll(-0.10, { move_cursor = false, duration = 100 }) end,
      ["<C-e>"] = function() neoscroll.scroll(0.10, { move_cursor = false, duration = 100 }) end,
      ["zt"] = function() neoscroll.zt({ duration = 250 }) end,
      ["zz"] = function() neoscroll.zz({ duration = 250 }) end,
      ["zb"] = function() neoscroll.zb({ duration = 250 }) end,
    }
    
    local modes = { "n", "v", "x" }
    for key, func in pairs(keymap) do
      vim.keymap.set(modes, key, func)
    end
  end,
}


