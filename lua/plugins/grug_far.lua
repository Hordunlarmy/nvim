-- A deliberately small, literal search-and-replace workflow.
-- Grug Far remains installed for advanced work, but the everyday mappings below
-- never expose its multi-field interface.

local function replace_literal(text, search, replacement)
  local pieces, count, from = {}, 0, 1
  while true do
    local start_at, end_at = text:find(search, from, true)
    if not start_at then break end
    pieces[#pieces + 1] = text:sub(from, start_at - 1)
    pieces[#pieces + 1] = replacement
    from = end_at + 1
    count = count + 1
  end
  if count == 0 then return text, 0 end
  pieces[#pieces + 1] = text:sub(from)
  return table.concat(pieces), count
end

local function read_file(path)
  local file = io.open(path, "rb")
  if not file then return nil end
  local content = file:read("*a")
  file:close()
  return content
end

local function project_files(root)
  local completed = vim.system({ "rg", "--files", "--hidden", "--glob", "!.git" }, {
    cwd = root,
    text = true,
  }):wait()
  if completed.code ~= 0 then return {} end

  local files = {}
  for path in completed.stdout:gmatch("[^\n]+") do
    files[#files + 1] = vim.fs.joinpath(root, path)
  end
  return files
end

local function make_plan(scope, search, replacement, root)
  local plan, total = {}, 0
  local paths = scope == "buffer" and { vim.api.nvim_buf_get_name(0) } or project_files(root)

  for _, path in ipairs(paths) do
    local content
    if scope == "buffer" then
      content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
    else
      content = read_file(path)
    end

    -- Skip binary files; they should never be altered by a text replacement.
    if content and not content:find("\0", 1, true) then
      local updated, count = replace_literal(content, search, replacement)
      if count > 0 then
        local first_line = 1
        local preview_lines = {}
        for line in content:gmatch("([^\n]*)\n?") do
          if line:find(search, 1, true) then
            preview_lines[#preview_lines + 1] = { line = first_line, text = line }
          end
          first_line = first_line + 1
        end
        plan[#plan + 1] = { path = path, updated = updated, count = count, matches = preview_lines }
        total = total + count
      end
    end
  end
  return plan, total
end

local function apply_plan(plan)
  local changed_files = 0
  for _, item in ipairs(plan) do
    local bufnr = vim.fn.bufnr(item.path)
    if bufnr ~= -1 and vim.api.nvim_buf_is_loaded(bufnr) then
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(item.updated, "\n", { plain = true }))
      vim.api.nvim_buf_call(bufnr, function() vim.cmd("silent write") end)
    else
      local file = assert(io.open(item.path, "wb"))
      file:write(item.updated)
      file:close()
    end
    changed_files = changed_files + 1
  end
  vim.notify(("Replaced text in %d file%s."):format(changed_files, changed_files == 1 and "" or "s"), vim.log.levels.INFO)
end

local function show_review(plan, total, search, replacement, root)
  local lines = {
    ("Replace %q with %q"):format(search, replacement),
    ("%d match%s in %d file%s"):format(total, total == 1 and "" or "es", #plan, #plan == 1 and "" or "s"),
    "",
  }
  local shown = 0
  for _, item in ipairs(plan) do
    local relative = vim.fs.relpath(root, item.path) or item.path
    for _, match in ipairs(item.matches) do
      lines[#lines + 1] = ("%s:%d  %s"):format(relative, match.line, match.text)
      shown = shown + 1
      if shown == 80 then
        lines[#lines + 1] = "… additional matches not shown"
        break
      end
    end
    if shown == 80 then break end
  end
  lines[#lines + 1] = ""
  lines[#lines + 1] = "Enter: apply and save    Esc/q: cancel"

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = "search-replace-review"
  vim.bo[buf].bufhidden = "wipe"
  local width = math.min(math.max(70, math.floor(vim.o.columns * 0.72)), vim.o.columns - 4)
  local height = math.min(math.max(10, #lines), math.floor(vim.o.lines * 0.65))
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    border = "rounded",
    title = " Search & Replace — review ",
    title_pos = "center",
    style = "minimal",
  })
  vim.wo[win].wrap = false
  vim.keymap.set("n", "<CR>", function()
    if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
    apply_plan(plan)
  end, { buffer = buf, nowait = true, desc = "Apply replacement" })
  for _, key in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set("n", key, function()
      if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
    end, { buffer = buf, nowait = true, desc = "Cancel replacement" })
  end
end

local function start_replace(scope, initial_search)
  vim.ui.input({ prompt = "Search for (literal text): ", default = initial_search or "" }, function(search)
    if not search or search == "" then return end
    if search:find("\n", 1, true) then
      return vim.notify("Multi-line search is not supported by the quick replace tool.", vim.log.levels.WARN)
    end
    vim.ui.input({ prompt = "Replace with (blank is allowed): " }, function(replacement)
      if replacement == nil then return end
      local function review(root)
        local plan, total = make_plan(scope, search, replacement, root)
        if total == 0 then return vim.notify("No literal matches found.", vim.log.levels.INFO) end
        show_review(plan, total, search, replacement, root)
      end
      if scope == "folder" then
        vim.ui.input({ prompt = "Folder: ", default = vim.fn.getcwd() }, function(folder)
          if folder and folder ~= "" then review(vim.fn.fnamemodify(folder, ":p")) end
        end)
      else
        review(scope == "buffer" and vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h") or vim.fn.getcwd())
      end
    end)
  end)
end

return {
  "MagicDuck/grug-far.nvim",
  config = function()
    require("grug-far").setup({ transient = true })
  end,
  keys = {
    {
      "<leader>sr",
      function()
        vim.ui.select({ "Current buffer", "Project folder", "Choose folder" }, { prompt = "Search and replace in" }, function(choice)
          if choice == "Current buffer" then return start_replace("buffer") end
          if choice == "Project folder" then return start_replace("project") end
          if choice == "Choose folder" then return start_replace("folder") end
        end)
      end,
      desc = "Search & Replace (choose scope)",
    },
    { "<leader>sw", function() start_replace("project", vim.fn.expand("<cword>")) end, desc = "Replace word under cursor (project)" },
    { "<leader>sf", function() start_replace("buffer") end, desc = "Search & Replace (current buffer)" },
  },
}
