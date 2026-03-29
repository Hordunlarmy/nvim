local M = {}

local function git_root_for_file(file)
  local file_dir = vim.fs.dirname(file)
  local root = vim.fn.systemlist({ "git", "-C", file_dir, "rev-parse", "--show-toplevel" })[1]
  if vim.v.shell_error ~= 0 or not root or root == "" then
    return nil
  end
  return root
end

local function relative_path(root, file)
  if vim.fs and type(vim.fs.relpath) == "function" then
    return vim.fs.relpath(root, file) or file
  end
  return file
end

function M.show_unified_diff_popup(opts)
  opts = opts or {}
  local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(bufnr)
  if file == "" then
    vim.notify("No file to diff", vim.log.levels.WARN)
    return false
  end

  local root = git_root_for_file(file)
  if not root then
    vim.notify("Not inside a git repository", vim.log.levels.WARN)
    return false
  end

  local rel = relative_path(root, file)
  local cmd = { "git", "-C", root, "--no-pager", "diff" }
  local rev = opts.rev
  if type(rev) == "string" and rev ~= "" then
    table.insert(cmd, rev)
  end
  table.insert(cmd, "--")
  table.insert(cmd, rel)

  local lines = vim.fn.systemlist(cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify("git diff failed for current file", vim.log.levels.ERROR)
    return false
  end

  if #lines == 0 then
    lines = { "No diff for current file." }
  end

  local cur_win = vim.api.nvim_get_current_win()
  local win_w = vim.api.nvim_win_get_width(cur_win)
  local win_h = vim.api.nvim_win_get_height(cur_win)
  local width = math.min(math.max(70, math.floor(win_w * 0.94)), 170)
  local height = math.min(math.max(10, math.floor(win_h * 0.82)), math.max(3, #lines + 2))
  local row = math.max(0, math.floor((win_h - height) / 2))
  local col = math.max(0, math.floor((win_w - width) / 2))

  local diff_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[diff_buf].buftype = "nofile"
  vim.bo[diff_buf].bufhidden = "wipe"
  vim.bo[diff_buf].swapfile = false
  vim.bo[diff_buf].filetype = "diff"
  vim.api.nvim_buf_set_lines(diff_buf, 0, -1, false, lines)

  local diff_win = vim.api.nvim_open_win(diff_buf, true, {
    relative = "win",
    win = cur_win,
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
  })

  vim.wo[diff_win].wrap = false
  vim.wo[diff_win].number = false
  vim.wo[diff_win].relativenumber = false
  vim.wo[diff_win].cursorline = true

  local function close_diff()
    if vim.api.nvim_win_is_valid(diff_win) then
      vim.api.nvim_win_close(diff_win, true)
    end
  end
  vim.keymap.set("n", "q", close_diff, { buffer = diff_buf, nowait = true, silent = true })
  vim.keymap.set("n", "<Esc>", close_diff, { buffer = diff_buf, nowait = true, silent = true })

  return true
end

return M
