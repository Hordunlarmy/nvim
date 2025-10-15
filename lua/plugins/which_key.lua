-- which-key: displays a popup with possible key bindings
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  keys = {
    {
      "<leader><leader>",
      "<cmd>Telescope keymaps<cr>",
      desc = "Search Keymaps",
    },
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  config = function()
    local wk = require("which-key")
    
    wk.setup({
      preset = "modern",
      delay = 300,
      plugins = {
        marks = true,
        registers = true,
        spelling = {
          enabled = true,
          suggestions = 20,
        },
        presets = {
          operators = true,
          motions = true,
          text_objects = true,
          windows = true,
          nav = true,
          z = true,
          g = true,
        },
      },
      win = {
        border = "rounded",  -- White border
        padding = { 2, 4 },  -- More padding
        wo = {
          winblend = 0,  -- Opaque
        },
      },
      layout = {
        spacing = 3,
        align = "left",
      },
      sort = { "alphanum", "order", "local", "group" },  -- Sort alphabetically
      filter = function(mapping)
        -- Filter function - return true to show mapping
        return true
      end,
      -- Enable search/filter
      triggers = {
        { "<auto>", mode = "nxso" },
      },
      defer = function(ctx)
        return ctx.mode == "V" or ctx.mode == "<C-V>"
      end,
    })

    -- Register key groups and mappings (v3 API) - ALPHABETICALLY SORTED!
    wk.add({
      -- Leader key groups (a-z order) - ONLY GROUPS at root level for clean menu
      { "<leader>a", group = "avante/ai" },
      { "<leader>b", group = "buffer" },
      { "<leader>c", group = "code/docs" },
      { "<leader>d", group = "diagnostics" },
      { "<leader>e", group = "explore/tree" },
      { "<leader>f", group = "find/telescope" },
      { "<leader>g", group = "git/goto" },
      { "<leader>h", group = "harpoon" },
      { "<leader>i", group = "inline/refactor" },
      { "<leader>m", group = "markdown" },
      { "<leader>n", group = "navigation" },
      { "<leader>o", group = "outline/aerial" },
      { "<leader>p", group = "project/paste" },
      { "<leader>q", group = "session/quit" },
      { "<leader>r", group = "run/rename" },
      { "<leader>s", group = "search/replace/source" },
      { "<leader>t", group = "terminal/toggle" },
      { "<leader>u", group = "ui" },
      { "<leader>x", group = "trouble/diagnostics" },
      { "<leader>y", group = "yank" },
      
      -- Mini.surround (gs prefix)
      { "gs", group = "surround" },
      { "gsa", desc = "Add surrounding" },
      { "gsd", desc = "Delete surrounding" },
      { "gsr", desc = "Replace surrounding" },
      { "gsf", desc = "Find surrounding (right)" },
      { "gsF", desc = "Find surrounding (left)" },
      { "gsh", desc = "Highlight surrounding" },
      { "gsn", desc = "Update n_lines" },
      
      -- Comment.nvim (gc prefix)
      { "gc", group = "comment" },
      { "gcc", desc = "Toggle comment line" },
      { "gcb", desc = "Toggle comment block" },
      { "gc", desc = "Toggle comment", mode = "v" },
      
      -- LSP (go-to mappings)
      { "gd", desc = "Go to definition" },
      { "gD", desc = "Go to declaration" },
      { "gr", desc = "References" },
      { "gi", desc = "Go to implementation" },
      { "K", desc = "Hover documentation" },
      
      -- Harpoon (<leader>h prefix) - alphabetically sorted
      { "<leader>h1", desc = "Harpoon file 1" },
      { "<leader>h2", desc = "Harpoon file 2" },
      { "<leader>h3", desc = "Harpoon file 3" },
      { "<leader>h4", desc = "Harpoon file 4" },
      { "<leader>ha", desc = "Harpoon add file" },
      { "<leader>hh", desc = "Harpoon menu" },
      { "<leader>hn", desc = "Harpoon next" },
      { "<leader>hp", desc = "Harpoon prev" },
      
      -- Session (persistence) - alphabetically sorted
      { "<leader>qd", desc = "Don't save session" },
      { "<leader>ql", desc = "Restore last session" },
      { "<leader>qs", desc = "Restore session" },
      { "<leader>qw", desc = "Save session NOW" },
      
      -- Search/Replace (grug-far)
      { "<leader>sr", desc = "Search & Replace" },
      { "<leader>sw", desc = "Search word under cursor" },
      { "<leader>sf", desc = "Search in current file" },
      
      -- Terminal (alphabetically sorted)
      { "<leader>tf", desc = "Float terminal" },
      { "<leader>th", desc = "Horizontal terminal" },
      { "<leader>tv", desc = "Vertical terminal" },
      { "<leader>tw", desc = "Toggle Twilight" },
      
      -- Buffer operations (alphabetically sorted)
      { "<leader>bc", desc = "Pick close buffer" },
      { "<leader>bd", desc = "Delete buffer" },
      { "<leader>bD", desc = "Delete buffer (force)" },
      { "<leader>bh", desc = "Close left buffers" },
      { "<leader>bl", desc = "Close right buffers" },
      { "<leader>bp", desc = "Pick buffer" },
      
      -- UI toggles (alphabetically sorted)
      { "<leader>un", desc = "Dismiss notifications" },
      { "<leader>tb", desc = "Toggle git blame" },
      { "<leader>tg", desc = "Toggle git deleted" },
      
      -- Markdown
      { "<leader>mp", desc = "Markdown Preview" },
      
      -- Code/Docs (Neogen) - alphabetically sorted
      { "<leader>ca", desc = "Code actions (LSP)" },
      { "<leader>cc", desc = "Generate docs (auto)" },
      { "<leader>ce", desc = "Enable completion" },
      { "<leader>cf", desc = "Generate function docs" },
      { "<leader>ci", desc = "Generate file docs" },
      { "<leader>cl", desc = "Generate class docs" },
      { "<leader>ct", desc = "Generate type docs" },
      
      -- Trouble (diagnostics)
      { "<leader>xx", desc = "Toggle Trouble" },
      { "<leader>xw", desc = "Workspace diagnostics" },
      { "<leader>xd", desc = "Document diagnostics" },
      { "<leader>xq", desc = "Quickfix list" },
      { "<leader>xl", desc = "Location list" },
      
      -- Git (gitsigns) - using <leader>g prefix
      { "<leader>gb", desc = "Git blame line" },
      { "<leader>gp", desc = "Git preview hunk" },
      { "<leader>gr", desc = "Git reset hunk", mode = { "n", "v" } },
      { "<leader>gra", desc = "Git reset all (buffer)" },
      { "<leader>gs", desc = "Git stage hunk", mode = { "n", "v" } },
      { "<leader>gsa", desc = "Git stage all (buffer)" },
      { "<leader>gt", desc = "Git diff this" },
      { "<leader>gT", desc = "Git diff this ~" },
      { "<leader>gu", desc = "Git undo stage" },
      { "]h", desc = "Next git hunk" },
      { "[h", desc = "Previous git hunk" },
      
      -- Telescope (under <leader>f) - alphabetically sorted
      { "<leader>/", desc = "Buffer fuzzy find" },
      { "<leader>fb", desc = "Buffers" },
      { "<leader>fd", desc = "LSP finder" },
      { "<leader>ff", desc = "Find files" },
      { "<leader>fg", desc = "Live grep" },
      { "<leader>fh", desc = "Command history" },
      { "<leader>fk", desc = "Search keymaps 🔍" },
      { "<leader>fl", desc = "LSP references" },
      { "<leader>fo", desc = "Old files" },
      { "<leader>fs", desc = "Grep string" },
      { "<leader>ft", desc = "Find todos" },
      { "<leader>fy", desc = "Yank history" },
      
      -- Code Runner (alphabetically sorted)
      { "<leader>r", desc = "Run code" },
      { "<leader>rc", desc = "Run close" },
      { "<leader>rf", desc = "Run file" },
      { "<leader>rn", desc = "Rename symbol (LSP)" },
      { "<leader>rp", desc = "Run project" },
      
      -- Diagnostics group (under <leader>d)
      { "<leader>d", desc = "Cursor diagnostics", group = "diagnostics" },
      { "<leader>D", desc = "Line diagnostics" },
      { "<leader>nd", desc = "Next diagnostic" },
      { "<leader>pd", desc = "Previous diagnostic" },
      
      -- Goto/LSP (under <leader>g)
      { "<leader>gd", desc = "LSP peek definition" },
      { "<leader>gD", desc = "LSP goto definition" },
      { "<leader>gS", desc = "LSP goto def (split)" },
      
      -- Window navigation (built-in)
      { "<C-h>", desc = "Window left" },
      { "<C-j>", desc = "Window down" },
      { "<C-k>", desc = "Window up" },
      { "<C-l>", desc = "Window right" },
      
      -- Resize windows
      { "<C-Left>", desc = "Decrease width" },
      { "<C-Right>", desc = "Increase width" },
      { "<C-Up>", desc = "Increase height" },
      { "<C-Down>", desc = "Decrease height" },
      
      -- Tree
      { "<leader>e", desc = "Toggle file tree" },
      
      -- Flash (jump)
      { "s", desc = "Flash jump", mode = { "n", "x", "o" } },
      { "S", desc = "Flash treesitter", mode = { "n", "x", "o" } },
      { "r", desc = "Remote flash", mode = "o" },
      { "R", desc = "Treesitter search", mode = { "o", "x" } },
      
      -- Save/quit shortcuts
      { "ww", desc = "Save file" },
      { "wq", desc = "Save and quit" },
      { "qq", desc = "Quit" },
      
      -- Visual mode
      { "J", desc = "Move line down", mode = "v" },
      { "K", desc = "Move line up", mode = "v" },
      { "<", desc = "Decrease indent", mode = "v" },
      { ">", desc = "Increase indent", mode = "v" },
      
      -- Yanky
      { "y", desc = "Yank" },
      { "p", desc = "Paste" },
      { "P", desc = "Paste before" },
      { "]p", desc = "Next paste" },
      { "[p", desc = "Previous paste" },
      
      -- Todo comments
      { "]t", desc = "Next todo" },
      { "[t", desc = "Previous todo" },
      
      -- Mini.ai text objects (works with operators like d, c, v, y)
      { "a", group = "around textobj" },
      { "i", group = "inside textobj" },
      { "af", desc = "Around function", mode = { "o", "x" } },
      { "if", desc = "Inside function", mode = { "o", "x" } },
      { "ac", desc = "Around class", mode = { "o", "x" } },
      { "ic", desc = "Inside class", mode = { "o", "x" } },
      { "ao", desc = "Around block/loop/cond", mode = { "o", "x" } },
      { "io", desc = "Inside block/loop/cond", mode = { "o", "x" } },
      { "at", desc = "Around HTML tag", mode = { "o", "x" } },
      { "it", desc = "Inside HTML tag", mode = { "o", "x" } },
      
      -- Refactoring (extract/inline)
      { "<leader>ef", desc = "Extract function", mode = { "n", "v" } },
      { "<leader>ev", desc = "Extract variable", mode = { "n", "v" } },
      { "<leader>i", group = "inline/refactor" },
      { "<leader>iv", desc = "Inline variable" },
      
      -- Explore/Tree (under <leader>e)
      { "<leader>e", desc = "Toggle NvimTree" },
      
      -- Outline/Aerial (under <leader>o)
      { "<leader>o", desc = "Toggle Outline (Aerial)" },
      { "<leader>O", desc = "Aerial Navigation Float" },
      
      -- Project/Paste (under <leader>p)
      { "<leader>pv", desc = "Ex mode" },
      { "<leader>p", desc = "Paste without overwrite", mode = "x" },
      
      -- Source/reload (under <leader>s)
      { "<leader>so", desc = "Reload config" },
      
      -- Yank (under <leader>y)
      { "<leader>y", desc = "Yank to clipboard", mode = { "n", "v" } },
      { "<leader>Y", desc = "Yank line to clipboard" },
      
      -- Diagnostics navigation
      { "[d", desc = "Previous diagnostic" },
      { "]d", desc = "Next diagnostic" },
      
      -- Avante AI (alphabetically sorted)
      { "<leader>a?", desc = "Select model" },
      { "<leader>aa", desc = "Avante ask" },
      { "<leader>ac", desc = "Add current to context" },
      { "<leader>ae", desc = "Avante edit" },
      { "<leader>af", desc = "Avante focus" },
      { "<leader>ah", desc = "Select history" },
      { "<leader>ar", desc = "Avante refresh" },
      { "<leader>at", desc = "Avante toggle" },
      
      -- Special keys
      { "<leader><leader>", desc = "Search ALL keymaps 🔍" },
      { "<leader>?", desc = "Show buffer keymaps" },
      { "<C-f>", desc = "Telescope live grep" },
      { "<C-\\>", desc = "Toggle terminal" },
      { "<A-d>", desc = "LSP terminal" },
      
      -- Vim-matchup (enhanced % navigation)
      { "%", desc = "Jump to matching pair (matchup)" },
      { "g%", desc = "Reverse jump to matching pair" },
      
      -- Scroll (Neoscroll)
      { "<C-Up>", desc = "Scroll up (smooth)" },
      { "<C-Down>", desc = "Scroll down (smooth)" },
      { "<C-b>", desc = "Page up (smooth)" },
      { "<C-d>", desc = "Half page down (centered)" },
      { "<C-u>", desc = "Half page up (centered)" },
      { "zt", desc = "Top of screen (smooth)" },
      { "zz", desc = "Center screen (smooth)" },
      { "zb", desc = "Bottom of screen (smooth)" },
      
      -- Mini.ai examples for clarity
      { "dif", desc = "Delete inside function", mode = "n" },
      { "daf", desc = "Delete around function", mode = "n" },
      { "dic", desc = "Delete inside class", mode = "n" },
      { "dac", desc = "Delete around class", mode = "n" },
      { "vif", desc = "Select inside function", mode = "n" },
      { "vac", desc = "Select around class", mode = "n" },
      { "cif", desc = "Change inside function", mode = "n" },
      { "yaf", desc = "Yank around function", mode = "n" },
    })
  end,
}

