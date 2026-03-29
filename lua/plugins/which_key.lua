-- which-key: displays a popup with possible key bindings
local function center_telescope_in_window(anchor_win)
  if not anchor_win or not vim.api.nvim_win_is_valid(anchor_win) then
    return false
  end

  local float_wins = {}
  local min_row, min_col, max_row, max_col
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.bo[buf].filetype
    if ft == "TelescopePrompt" or ft == "TelescopeResults" or ft == "TelescopePreview" then
      local cfg = vim.api.nvim_win_get_config(win)
      if cfg and cfg.relative ~= "" then
        local row = tonumber(cfg.row) or 0
        local col = tonumber(cfg.col) or 0
        local width = tonumber(cfg.width) or 1
        local height = tonumber(cfg.height) or 1

        min_row = min_row and math.min(min_row, row) or row
        min_col = min_col and math.min(min_col, col) or col
        max_row = max_row and math.max(max_row, row + height + 2) or (row + height + 2)
        max_col = max_col and math.max(max_col, col + width + 2) or (col + width + 2)
        float_wins[#float_wins + 1] = { win = win, cfg = cfg, row = row, col = col }
      end
    end
  end

  if #float_wins == 0 or min_row == nil or min_col == nil or max_row == nil or max_col == nil then
    return false
  end

  local anchor_w = vim.api.nvim_win_get_width(anchor_win)
  local anchor_h = vim.api.nvim_win_get_height(anchor_win)
  local box_w = math.max(1, math.floor(max_col - min_col))
  local box_h = math.max(1, math.floor(max_row - min_row))
  local target_row = math.max(0, math.floor((anchor_h - box_h) / 2))
  local target_col = math.max(0, math.floor((anchor_w - box_w) / 2))
  local delta_row = target_row - min_row
  local delta_col = target_col - min_col

  for _, item in ipairs(float_wins) do
    local cfg = item.cfg
    cfg.relative = "win"
    cfg.win = anchor_win
    cfg.row = math.max(0, item.row + delta_row)
    cfg.col = math.max(0, item.col + delta_col)
    pcall(vim.api.nvim_win_set_config, item.win, cfg)
  end

  return true
end

local function open_keymaps_picker(opts)
  opts = opts or {}
  local anchor_win = vim.api.nvim_get_current_win()
  local theme = require("telescope.themes").get_dropdown({
    prompt_title = opts.prompt_title or "Keymaps (search by key, desc, plugin)",
    default_text = opts.default_text,
    previewer = false,
    layout_strategy = "center",
    layout_config = {
      width = 0.9,
      height = 0.72,
    },
  })

  require("telescope.builtin").keymaps(vim.tbl_extend("force", theme, {
    show_plug = false,
  }))

  local retries = 20
  local function recenter()
    if center_telescope_in_window(anchor_win) then
      return
    end
    retries = retries - 1
    if retries <= 0 then
      return
    end
    vim.defer_fn(recenter, 25)
  end
  vim.defer_fn(recenter, 10)
end

return {
  "folke/which-key.nvim",
  lazy = false,
  keys = {
    {
      "<leader><leader>",
      function()
        open_keymaps_picker()
      end,
      desc = "Search Keymaps (desc + tags)",
    },
    {
      "<leader>fC",
      function()
        open_keymaps_picker({
          prompt_title = "Clojure Tooling Keymaps",
          default_text = "conjure",
        })
      end,
      desc = "Search Clojure keymaps (Conjure/Aerial)",
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
  end,
  config = function()
    local wk = require("which-key")
    
    wk.setup({
      preset = "modern",
      -- Small delay is more reliable than 0ms on busy startup.
      delay = 80,
      notify = false,
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
        no_overlap = true,
        border = "rounded",  -- White border
        padding = { 2, 4 },  -- More padding
        width = { min = 26, max = 80 },
        height = { min = 4, max = 22 },
        wo = {
          winblend = 0,  -- Opaque
        },
      },
      keys = {
        scroll_down = "<C-d>",
        scroll_up = "<C-u>",
      },
      layout = {
        spacing = 3,
        align = "left",
      },
      sort = { "order" },
      filter = function(mapping)
        -- Filter function - return true to show mapping
        return true
      end,
      triggers = {
        { "<leader>", mode = { "n", "v" } },
        { "<localleader>", mode = { "n", "v" } },
      },
      defer = function(ctx)
        return ctx.mode == "V" or ctx.mode == "<C-V>"
      end,
    })

    -- Register key groups and mappings (v3 API) - ALPHABETICALLY SORTED!
    wk.add({
      -- Leader key groups (a-z order) - ONLY GROUPS at root level for clean menu
      { "<leader>b", group = "buffer" },
      { "<leader>c", group = "code/docs" },
      { "<leader>d", group = "diagnostics" },
      { "<leader>e", group = "explore/tree" },
      { "<leader>f", group = "find/telescope" },
      { "<leader>g", group = "git/goto" },
      { "<leader>h", group = "harpoon" },
      { "<leader>i", group = "inline/refactor" },
      { "<leader>k", group = "sidekick" },
      { "<leader>m", group = "markdown" },
      { "<leader>n", group = "navigation" },
      { "<leader>o", group = "aerial/outline" },
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
      { "gcc", desc = "Toggle comment line ⚡" },
      { "gcb", desc = "Toggle comment block" },
      { "gc", desc = "Toggle comment", mode = "v" },
      { "gcap", desc = "Comment paragraph" },
      
      -- Copilot
      { "<M-l>", desc = "Accept Copilot suggestion", mode = "i" },
      { "<M-]>", desc = "Next Copilot suggestion", mode = "i" },
      { "<M-[>", desc = "Previous Copilot suggestion", mode = "i" },
      { "<C-]>", desc = "Dismiss Copilot", mode = "i" },
      
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
      { "<leader>uD", desc = "Toggle Drop effect" },
      { "<leader>uc", desc = "Force green cursor" },
      { "<leader>uh", desc = "Message history (popup)" },
      { "<leader>uH", desc = "Last message (details)" },
      { "<leader>uL", desc = "Rebuild LuaSnip (fix jsregexp)" },
      { "<leader>un", desc = "Dismiss notifications" },
      { "<leader>uN", desc = "Fix line numbers" },
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
      { "<leader>x", desc = "Delete (operator - no copy)" },
      { "<leader>xx", desc = "Toggle Trouble" },
      { "<leader>xw", desc = "Workspace diagnostics" },
      { "<leader>xd", desc = "Document diagnostics" },
      { "<leader>xq", desc = "Quickfix list" },
      { "<leader>xl", desc = "Location list" },
      
      -- Git (gitsigns) - using <leader>g prefix
      { "<leader>gb", desc = "Git blame buffer" },
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
      { "<leader>d", group = "diagnostics/delete" },
      { "<leader>do", desc = "Cursor diagnostic (click to copy!)" },
      { "<leader>dO", desc = "Line diagnostic (click to copy!)" },
      { "<leader>dt", desc = "Git diff popup (unified)" },
      { "<leader>db", desc = "Toggle diagnostics (buffer)" },
      { "<leader>dT", desc = "Toggle diagnostics (global)" },
      { "<leader>dk", desc = "Toggle diagnostics (Clojure)" },
      { "<leader>dK", desc = "Reset Clojure caches" },
      { "<leader>dc", desc = "Close split window" },
      { "<leader>dd", desc = "Delete line (no copy)", mode = { "n", "v" } },
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
      { "<leader>O", desc = "Aerial: Navigation Float" },
      
      -- Project/Paste (under <leader>p)
      { "<leader>pv", desc = "Ex mode" },
      { "<leader>p", desc = "Paste without overwrite", mode = "x" },
      
      -- Source/reload (under <leader>s)
      { "<leader>so", desc = "Reload config only" },
      { "<leader>sk", desc = "Check all API keys" },
      { "<leader>R", desc = "Reload config + env vars" },
      { "<F5>", desc = "Reload EVERYTHING (config + bashrc)" },
      
      -- Yank (under <leader>y)
      { "<leader>y", desc = "Yank to clipboard", mode = { "n", "v" } },
      { "<leader>Y", desc = "Yank line to clipboard" },
      
      -- Diagnostics navigation (quick bindings!)
      { "[d", desc = "Previous diagnostic" },
      { "]d", desc = "Next diagnostic" },
      { "[e", desc = "Previous error" },
      { "]e", desc = "Next error" },
      { "[w", desc = "Previous warning" },
      { "]w", desc = "Next warning" },
      
      -- Sidekick AI CLI / NES
      { "<leader>kd", desc = "Sidekick detach session" },
      { "<leader>ke", desc = "Sidekick toggle NES" },
      { "<leader>kf", desc = "Sidekick float popup" },
      { "<leader>kF", desc = "Sidekick focus split panel" },
      { "<leader>kk", desc = "Sidekick toggle CLI" },
      { "<leader>kn", desc = "Sidekick next/apply edit" },
      { "<leader>kp", desc = "Sidekick prompt", mode = { "n", "x" } },
      { "<leader>ks", desc = "Sidekick select tool" },
      { "<leader>kt", desc = "Sidekick send this", mode = { "n", "x" } },
      { "<leader>ku", desc = "Sidekick update edits" },
      { "<leader>kv", desc = "Sidekick send selection", mode = { "x" } },

      -- Conjure (Clojure REPL) - uses <localleader> (backslash \)
      -- Note: These are buffer-local, only active in .clj files
      { "<localleader>", group = "conjure/compojure repl" },
      { "<localleader>e", group = "conjure eval" },
      { "<localleader>eb", desc = "Conjure/Compojure: eval buffer" },
      { "<localleader>ee", desc = "Conjure/Compojure: eval form under cursor" },
      { "<localleader>er", desc = "Conjure/Compojure: eval root form" },
      { "<localleader>ew", desc = "Conjure/Compojure: eval word" },
      { "<localleader>e!", desc = "Conjure/Compojure: eval replace form" },
      { "<localleader>l", group = "conjure log" },
      { "<localleader>ls", desc = "Conjure/Compojure: show log" },
      { "<localleader>lq", desc = "Conjure/Compojure: close log" },
      { "<localleader>lt", desc = "Conjure/Compojure: toggle log" },
      { "<localleader>lr", desc = "Conjure/Compojure: reset log" },
      { "<localleader>s", group = "conjure session" },
      { "<localleader>sc", desc = "Conjure/Compojure: connect/select REPL" },
      { "<localleader>cd", desc = "Conjure/Compojure: disconnect" },
      { "<localleader>g", group = "conjure goto" },
      { "<localleader>gd", desc = "Conjure/Compojure: go to definition" },
      { "<localleader>v", group = "conjure view" },
      { "<localleader>vs", desc = "Conjure/Compojure: view source" },
      { "<localleader>vd", desc = "Conjure/Compojure: view doc" },
      
      -- Special keys
      { "<leader><leader>", desc = "Search ALL keymaps 🔍" },
      { "<leader>?", desc = "Show buffer keymaps" },
      { "<leader>;", desc = "Alpha dashboard (new tab) 🏠" },
      { "<C-.>", desc = "Sidekick focus" },
      { "<C-f>", desc = "Telescope live grep" },
      { "<A-f>", desc = "Telescope search (current file)" },
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

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("WhichKeyMouseScroll", { clear = true }),
      pattern = "which-key",
      callback = function(args)
        vim.keymap.set("n", "<ScrollWheelDown>", "<C-d>", { buffer = args.buf, noremap = true, silent = true, nowait = true })
        vim.keymap.set("n", "<ScrollWheelUp>", "<C-u>", { buffer = args.buf, noremap = true, silent = true, nowait = true })
      end,
    })
  end,
}
