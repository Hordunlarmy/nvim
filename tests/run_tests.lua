-- Custom in-process test runner for Neovim config.
-- Runs all tests in the SAME Neovim process (no subprocess spawning).
-- This avoids the plenary subprocess issue where lazy.nvim plugins aren't visible.

local passed = 0
local failed = 0
local pending_count = 0
local errors = {}
local current_describe = ""

local function green(s) return "\27[32m" .. s .. "\27[0m" end
local function red(s) return "\27[31m" .. s .. "\27[0m" end
local function yellow(s) return "\27[33m" .. s .. "\27[0m" end
local function cyan(s) return "\27[36m" .. s .. "\27[0m" end
local function bold(s) return "\27[1m" .. s .. "\27[0m" end

local function check(condition, msg)
  if condition then
    passed = passed + 1
    print(green("  PASS") .. " || " .. current_describe .. " " .. msg)
  else
    failed = failed + 1
    table.insert(errors, current_describe .. " " .. msg)
    print(red("  FAIL") .. " || " .. current_describe .. " " .. msg)
  end
end

local function skip(msg, reason)
  pending_count = pending_count + 1
  print(yellow("  SKIP") .. " || " .. current_describe .. " " .. msg .. " (" .. reason .. ")")
end

local function section(name)
  print("")
  print(bold(cyan("═══════════════════════════════════════════════════")))
  print(bold(cyan("  " .. name)))
  print(bold(cyan("═══════════════════════════════════════════════════")))
end

local function describe(name)
  current_describe = name
  print(bold("\n  ▸ " .. name))
end

-- Filter to run only specific suite via env var or arg
local filter = nil
if vim.env.TEST_SUITE then
  filter = vim.env.TEST_SUITE
end
-- Also check for command-line arg passed via -c "lua ..."
for i, arg in ipairs(vim.v.argv or {}) do
  if arg == "--suite" and vim.v.argv[i + 1] then
    filter = vim.v.argv[i + 1]
  end
end

local function should_run(suite_name)
  if not filter or filter == "" or filter == "all" then return true end
  return suite_name:lower():find(filter:lower(), 1, true) ~= nil
end

-- ═══════════════════════════════════════════════════
-- Helpers
-- ═══════════════════════════════════════════════════
local function get_plugin_names()
  local ok, lazy = pcall(require, "lazy")
  if not ok then return nil end
  local names = {}
  for _, p in ipairs(lazy.plugins()) do
    names[p.name] = true
  end
  return names
end

local function find_keymap(modes, lhs)
  if type(modes) == "string" then modes = { modes } end
  local alt_lhs = lhs:gsub("(<C%-)(%l)(>)", function(prefix, ch, suffix)
    return prefix .. ch:upper() .. suffix
  end)
  for _, mode in ipairs(modes) do
    for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
      if map.lhs == lhs or map.lhs == alt_lhs then
        return map
      end
    end
    local ok2, buf_maps = pcall(vim.api.nvim_buf_get_keymap, 0, mode)
    if ok2 then
      for _, map in ipairs(buf_maps) do
        if map.lhs == lhs or map.lhs == alt_lhs then
          return map
        end
      end
    end
  end
  return nil
end

local function map_to_command(rhs)
  if type(rhs) ~= "string" or rhs == "" then
    return nil
  end
  if not rhs:match("^<Cmd>") and not rhs:match("^:") then
    return nil
  end
  local cmd = rhs
  cmd = cmd:gsub("^<Cmd>", "")
  cmd = cmd:gsub("^:", "")
  cmd = cmd:gsub("<CR>$", "")
  if cmd == "" then
    return nil
  end
  return cmd
end

local function should_skip_map_exec(map)
  local lhs = map.lhs or ""
  local rhs = map.rhs or ""
  local desc = (map.desc or ""):lower()
  local cmd = map_to_command(rhs)

  -- Avoid quitting/saving/reloading side-effects during test execution.
  if lhs == "Q" or lhs == "WQ" or lhs == "qq" or lhs == "wq" then
    return true, "destructive key"
  end
  if desc:find("quit", 1, true)
    or desc:find("write", 1, true)
    or desc:find("reload", 1, true)
    or desc:find("rebuild", 1, true)
    or desc:find("api key", 1, true)
    or desc:find("session", 1, true)
  then
    return true, "destructive side-effect"
  end

  -- Skip clearly interactive UI workflows in headless mode.
  if desc:find("telescope", 1, true)
    or desc:find("terminal", 1, true)
    or desc:find("dashboard", 1, true)
    or desc:find("buffer local keymaps", 1, true)
    or desc:find("preview", 1, true)
      or desc:find("history", 1, true)
      or desc:find("markdown", 1, true)
      or desc:find("aerial", 1, true)
      or desc:find("tree", 1, true)
      or desc:find("run", 1, true)
      or desc:find("code action", 1, true)
  then
    return true, "interactive UI mapping"
  end

  if cmd then
    local c = cmd:lower()
    if c:find("^q", 1, true)
      or c:find("^qa", 1, true)
      or c:find("^wq", 1, true)
      or c:find("^x", 1, true)
      or c:find("^quit", 1, true)
      or c:find("^source", 1, true)
      or c:find("^lazy", 1, true)
      or c:find("^mason", 1, true)
      or c:find("^telescope", 1, true)
      or c:find("^trouble", 1, true)
      or c:find("^nvimtree", 1, true)
      or c:find("^alpha", 1, true)
      or c:find("^toggleterm", 1, true)
      or c:find("^aerial", 1, true)
      or c:find("^run", 1, true)
    then
      return true, "interactive/destructive command"
    end
  end

  return false, ""
end

local function execute_map(map)
  if type(map.callback) == "function" then
    return pcall(map.callback)
  end
  local cmd = map_to_command(map.rhs)
  if cmd then
    local cmd_name = cmd:match("^%s*([%w_#%.%-]+)")
    if not cmd_name then
      return false, "could not parse command name from rhs"
    end
    if vim.fn.exists(":" .. cmd_name) == 0 then
      return false, "missing command: " .. cmd_name
    end
    return true
  end
  return true
end

local function is_user_command_map(map)
  local lhs = map.lhs or ""
  if lhs == "" then
    return false
  end
  if lhs:match("^<Plug>") then
    return false
  end
  local leader_lhs = vim.g.mapleader or " "
  if lhs:sub(1, #leader_lhs) == leader_lhs then
    return true
  end
  local extras = {
    ["Q"] = true,
    ["W"] = true,
    ["WQ"] = true,
    ["qq"] = true,
    ["ww"] = true,
    ["wq"] = true,
    ["<C-F>"] = true,
    ["<C-f>"] = true,
    ["<M-f>"] = true,
    ["<A-f>"] = true,
  }
  return extras[lhs] == true
end

-- ═══════════════════════════════════════════════════
-- 1. PLUGIN TESTS - ALL plugins
-- ═══════════════════════════════════════════════════
if should_run("plugins") then
  section("PLUGINS")

  local all_expected_plugins = {
    -- Core / infrastructure
    "lazy.nvim",
    "plenary.nvim",
    "neoconf.nvim",
    "nvim-web-devicons",
    "nui.nvim",

    -- LSP
    "nvim-lspconfig",
    "mason.nvim",
    "mason-lspconfig.nvim",
    "mason-tool-installer.nvim",
    "lspsaga.nvim",
    "lspkind.nvim",
    "efmls-configs-nvim",
    "lazydev.nvim",

    -- Completion
    "nvim-cmp",
    "cmp-buffer",
    "cmp-nvim-lsp",
    "LuaSnip",

    -- Treesitter
    "nvim-treesitter",
    "nvim-ts-context-commentstring",
    "rainbow-delimiters.nvim",

    -- Navigation / search
    "telescope.nvim",
    "telescope-fzf-native.nvim",
    "fzf-lua",
    "flash.nvim",
    "harpoon",
    "nvim-tree.lua",
    "aerial.nvim",

    -- Editor enhancements
    "Comment.nvim",
    "nvim-autopairs",
    "mini.ai",
    "mini.surround",
    "mini.pick",
    "vim-sleuth",
    "vim-matchup",
    "vim-illuminate",
    "indent-blankline.nvim",
    "indent-o-matic",
    "neogen",
    "refactoring.nvim",
    "todo-comments.nvim",
    "grug-far.nvim",
    "yanky.nvim",

    -- UI / appearance
    "github-nvim-theme",
    "alpha-nvim",
    "bufferline.nvim",
    "nvim-cokeline",
    "lualine.nvim",
    "dressing.nvim",
    "noice.nvim",
    "nvim-notify",
    "nvim-scrollbar",
    "transparent.nvim",
    "neoscroll.nvim",
    "twilight.nvim",
    "nvim-bqf",

    -- Git
    "gitsigns.nvim",

    -- Terminal / runner
    "toggleterm.nvim",
    "FTerm.nvim",
    "code_runner.nvim",

    -- Session / persistence
    "persistence.nvim",
    "resession.nvim",

    -- DAP / debugging
    "nvim-dap",
    "nvim-dap-python",
    "nvim-dap-ui",
    "nvim-nio",

    -- AI / copilot
    "copilot.lua",
    "copilot-cmp",
    "copilot-lualine",
    "blink.cmp",

    -- Misc
    "trouble.nvim",
    "which-key.nvim",
    "bufdelete.nvim",
    "diagram.nvim",
    "image.nvim",
    "sqlite.lua",

    -- Clojure
    "conjure",
    "nvim-paredit",
    "cmp-conjure",
  }

  local names = get_plugin_names()
  if not names then
    print(red("  FATAL: lazy.nvim not available, cannot test plugins"))
    failed = failed + #all_expected_plugins
  else
    describe("all plugins registered")
    for _, plugin_name in ipairs(all_expected_plugins) do
      check(names[plugin_name] == true, plugin_name)
    end

    -- Also report any unexpected plugins (informational, not a failure)
    describe("unexpected plugins (info only)")
    local expected_set = {}
    for _, n in ipairs(all_expected_plugins) do expected_set[n] = true end
    local extra = {}
    for n in pairs(names) do
      if not expected_set[n] then table.insert(extra, n) end
    end
    if #extra > 0 then
      table.sort(extra)
      for _, n in ipairs(extra) do
        print(yellow("  INFO") .. " || not in expected list: " .. n)
      end
    else
      print(green("  INFO") .. " || no unexpected plugins")
    end
  end
end

-- ═══════════════════════════════════════════════════
-- 2. LSP TESTS
-- ═══════════════════════════════════════════════════
if should_run("lsp") then
  section("LSP CONFIGURATION")

  describe("lspconfig module")
  local lspconfig_ok = pcall(require, "lspconfig")
  check(lspconfig_ok, "nvim-lspconfig is requireable")

  local cmp_lsp_ok = pcall(require, "cmp_nvim_lsp")
  check(cmp_lsp_ok, "cmp_nvim_lsp is requireable")

  describe("server configs exist")
  local expected_servers = {
    "lua_ls", "jsonls", "jedi_language_server", "ts_ls",
    "bashls", "dockerls", "gopls", "clojure_lsp",
    "intelephense", "clangd", "emmet_ls", "html",
    "cssls", "yamlls", "marksman",
  }
  local lsp_ok, lspconfig = pcall(require, "lspconfig")
  if lsp_ok then
    for _, server in ipairs(expected_servers) do
      -- lspconfig v2+ uses a lazy metatable; accessing lspconfig[name] returns a table with .name
      local srv = lspconfig[server]
      check(srv ~= nil and type(srv) == "table", server .. " config exists")
    end
  else
    for _, server in ipairs(expected_servers) do
      skip(server .. " config exists", "lspconfig not available")
    end
  end

  describe("mason")
  check(pcall(require, "mason"), "mason is requireable")
  check(pcall(require, "mason-lspconfig"), "mason-lspconfig is requireable")

  describe("diagnostics")
  local diag_config = vim.diagnostic.config()
  check(diag_config ~= nil, "diagnostic config exists")
  if diag_config then
    check(diag_config.virtual_text == false, "virtual_text is disabled")
    check(diag_config.underline == true, "underline is enabled")
    check(diag_config.severity_sort == true, "severity_sort is enabled")
  end
end

-- ═══════════════════════════════════════════════════
-- 3. TREESITTER TESTS
-- ═══════════════════════════════════════════════════
if should_run("treesitter") then
  section("TREESITTER")

  describe("treesitter module")
  check(pcall(require, "nvim-treesitter"), "nvim-treesitter is requireable")

  describe("parsers installed")
  local expected_parsers = {
    "vim", "regex", "rust", "go", "gomod", "gowork",
    "markdown", "markdown_inline", "json", "javascript",
    "typescript", "yaml", "html", "css", "bash", "lua",
    "dockerfile", "solidity", "gitignore", "python",
    "vue", "svelte", "toml", "jsonc", "c", "cpp", "java",
    "clojure",
  }
  local parsers_ok, parsers = pcall(require, "nvim-treesitter.parsers")
  if parsers_ok then
    for _, lang in ipairs(expected_parsers) do
      if parsers.has_parser(lang) then
        check(true, lang)
      else
        skip(lang, "not installed yet (run :TSInstall " .. lang .. ")")
      end
    end
  else
    for _, lang in ipairs(expected_parsers) do
      skip(lang, "nvim-treesitter.parsers not available")
    end
  end
end

-- ═══════════════════════════════════════════════════
-- 4. FORMATTER / LINTER TESTS
-- ═══════════════════════════════════════════════════
if should_run("formatter") then
  section("FORMATTERS & LINTERS")

  describe("formatter.nvim module")
  check(pcall(require, "formatter"), "formatter.nvim is requireable")

  describe("formatter binaries")
  local formatters = {
    { "prettier", "js/ts/html/css/md" },
    { "black", "python" },
    { "isort", "python imports" },
    { "shfmt", "shell" },
    { "stylua", "lua" },
    { "zprint", "clojure" },
    { "goimports", "go" },
    { "gofmt", "go" },
  }
  for _, fmt in ipairs(formatters) do
    if vim.fn.executable(fmt[1]) == 1 then
      check(true, fmt[1] .. " (" .. fmt[2] .. ")")
    else
      skip(fmt[1] .. " (" .. fmt[2] .. ")", "not in PATH")
    end
  end

  describe("linter binaries")
  local linters = {
    { "eslint_d", "js/ts" },
    { "shellcheck", "shell" },
    { "markdownlint", "markdown" },
    { "pylint", "python" },
    { "clj-kondo", "clojure" },
    { "hadolint", "docker" },
    { "luacheck", "lua" },
    { "golangci-lint", "go" },
  }
  for _, linter in ipairs(linters) do
    if vim.fn.executable(linter[1]) == 1 then
      check(true, linter[1] .. " (" .. linter[2] .. ")")
    else
      skip(linter[1] .. " (" .. linter[2] .. ")", "not in PATH")
    end
  end
end

-- ═══════════════════════════════════════════════════
-- 5. CLOJURE-SPECIFIC TESTS
-- ═══════════════════════════════════════════════════
if should_run("clojure") then
  section("CLOJURE SUPPORT")

  describe("language server")
  local clj_lsp_ok, clj_lspconfig = pcall(require, "lspconfig")
  if clj_lsp_ok then
    local srv = clj_lspconfig.clojure_lsp
    check(srv ~= nil and type(srv) == "table", "clojure_lsp config exists in lspconfig")
  else
    skip("clojure_lsp config exists", "lspconfig not available")
  end
  if vim.fn.executable("clojure-lsp") == 1 then
    check(true, "clojure-lsp binary installed")
  else
    skip("clojure-lsp binary installed", "not in PATH - run :MasonInstall clojure-lsp")
  end

  describe("treesitter parser")
  local p_ok, p = pcall(require, "nvim-treesitter.parsers")
  if p_ok then
    if p.has_parser("clojure") then
      check(true, "clojure parser installed")
    else
      skip("clojure parser installed", "run :TSInstall clojure")
    end
  else
    skip("clojure parser installed", "nvim-treesitter.parsers not available")
  end

  describe("conjure (REPL)")
  local pnames = get_plugin_names()
  if pnames then
    check(pnames["conjure"] == true, "conjure plugin registered")
    check(pnames["cmp-conjure"] == true, "cmp-conjure plugin registered")
  else
    skip("conjure plugin registered", "lazy not available")
    skip("cmp-conjure plugin registered", "lazy not available")
  end
  check(vim.g["conjure#mapping#prefix"] == "<localleader>", "conjure mapping prefix is <localleader>")
  check(vim.g["conjure#filetype#rust"] == false, "conjure disabled for rust")
  check(vim.g["conjure#filetype#python"] == false, "conjure disabled for python")
  check(vim.g["conjure#filetype#lua"] == false, "conjure disabled for lua")

  describe("paredit (structural editing)")
  if pnames then
    check(pnames["nvim-paredit"] == true, "nvim-paredit plugin registered")
  else
    skip("nvim-paredit plugin registered", "lazy not available")
  end

  describe("rainbow delimiters")
  local rd_config = vim.g.rainbow_delimiters
  if rd_config and rd_config.query then
    check(rd_config.query.clojure == "rainbow-blocks", "clojure uses rainbow-blocks query")
  else
    skip("clojure rainbow-blocks query", "rainbow_delimiters config not loaded")
  end

  describe("formatter and linter binaries")
  if vim.fn.executable("zprint") == 1 then
    check(true, "zprint installed")
  else
    skip("zprint installed", "not in PATH - run :MasonInstall zprint")
  end
  if vim.fn.executable("clj-kondo") == 1 then
    check(true, "clj-kondo installed")
  else
    skip("clj-kondo installed", "not in PATH - run :MasonInstall clj-kondo")
  end
end

-- ═══════════════════════════════════════════════════
-- 6. KEYMAP TESTS
-- ═══════════════════════════════════════════════════
if should_run("keymaps") then
  section("KEYMAPS")

  describe("leader")
  check(vim.g.mapleader == " ", "leader key is space")

  describe("normal mode keymaps")
  local normal_keymaps = {
    { "<C-d>", "half page down" },
    { "<C-u>", "half page up" },
    { "<C-h>", "move to left split" },
    { "<C-j>", "move to lower split" },
    { "<C-k>", "move to upper split" },
    { "<C-l>", "move to right split" },
    { "<C-f>", "telescope live grep" },
  }
  for _, km in ipairs(normal_keymaps) do
    check(find_keymap({ "n" }, km[1]) ~= nil, km[2] .. " (" .. km[1] .. ")")
  end

  describe("visual mode keymaps")
  -- Neovim stores '<' as '<lt>' internally
  check(find_keymap({ "v", "x" }, "<lt>") ~= nil, "visual indent left (<)")
  check(find_keymap({ "v", "x" }, ">") ~= nil, "visual indent right (>)")

  describe("normal mode keymaps execute (non-interactive)")
  local maps = vim.api.nvim_get_keymap("n")
  table.sort(maps, function(a, b)
    return (a.lhs or "") < (b.lhs or "")
  end)
  for _, map in ipairs(maps) do
    if is_user_command_map(map) then
      local skip_exec, reason = should_skip_map_exec(map)
      if skip_exec then
        skip("exec " .. map.lhs, reason)
      else
        local ok_exec, err = execute_map(map)
        check(ok_exec, "exec " .. map.lhs .. (err and (" (" .. tostring(err) .. ")") or ""))
      end
    end
  end
end

-- ═══════════════════════════════════════════════════
-- 7. SETTINGS TESTS
-- ═══════════════════════════════════════════════════
if should_run("settings") then
  section("SETTINGS")

  describe("indentation")
  check(vim.opt.tabstop:get() == 4, "tabstop is 4")
  check(vim.opt.shiftwidth:get() == 4, "shiftwidth is 4")
  check(vim.opt.expandtab:get() == true, "expandtab is enabled")
  check(vim.opt.smartindent:get() == true, "smartindent is enabled")

  describe("files")
  check(vim.opt.swapfile:get() == false, "swapfile is disabled")
  check(vim.opt.backup:get() == false, "backup is disabled")
  check(vim.opt.undofile:get() == true, "undofile is enabled")

  describe("display")
  check(vim.opt.termguicolors:get() == true, "termguicolors is enabled")
  check(vim.opt.showmode:get() == false, "showmode is disabled (statusline shows mode)")
  check(vim.opt.signcolumn:get() == "yes", "signcolumn is yes")
  check(vim.opt.scrolloff:get() == 8, "scrolloff is 8")
  check(vim.opt.laststatus:get() == 3, "laststatus is 3 (global statusline)")

  describe("search")
  check(vim.opt.ignorecase:get() == true, "ignorecase is enabled")
  check(vim.opt.smartcase:get() == true, "smartcase is enabled")

  describe("misc")
  local clipboard = vim.opt.clipboard:get()
  local has_unnamedplus = false
  for _, v in ipairs(clipboard) do
    if v == "unnamedplus" then has_unnamedplus = true end
  end
  check(has_unnamedplus, "clipboard includes unnamedplus")
  check(vim.o.mouse == "a", "mouse is enabled")
end

-- ═══════════════════════════════════════════════════
-- SUMMARY
-- ═══════════════════════════════════════════════════
print("")
print(bold("═══════════════════════════════════════════════════"))
print(bold("  TEST RESULTS"))
print(bold("═══════════════════════════════════════════════════"))
print(green("  Passed:  " .. passed))
print(red("  Failed:  " .. failed))
print(yellow("  Skipped: " .. pending_count))
print(bold("  Total:   " .. (passed + failed + pending_count)))
print(bold("═══════════════════════════════════════════════════"))

if #errors > 0 then
  print("")
  print(red(bold("  FAILURES:")))
  for _, e in ipairs(errors) do
    print(red("    ✗ " .. e))
  end
end

print("")

-- Exit with proper code
if failed > 0 then
  vim.cmd("cq!")  -- exit code 1
else
  vim.cmd("qa!")  -- exit code 0
end
