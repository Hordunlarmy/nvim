local M = {}
local async_cmd = require("util.async_cmd")

local function git_root_for_file_async(file, cb)
  local file_dir = vim.fs.dirname(file)
  async_cmd.run_lines(
    { "git", "-C", file_dir, "rev-parse", "--show-toplevel" },
    {
      timeout_ms = 2500,
      progress_key = "git_popup_root",
      progress_label = "Resolving git root",
    },
    function(result)
      local root = result.stdout_lines and result.stdout_lines[1] or nil
      if result.code ~= 0 or not root or root == "" then
        cb(nil)
        return
      end
      cb(root)
    end
  )
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

  git_root_for_file_async(file, function(root)
    if not root then
      vim.notify("Not inside a git repository", vim.log.levels.WARN)
      return
    end

    local rel = relative_path(root, file)
    local cmd = { "git", "-C", root, "--no-pager", "diff" }
    local rev = opts.rev
    if type(rev) == "string" and rev ~= "" then
      table.insert(cmd, rev)
    end
    table.insert(cmd, "--")
    table.insert(cmd, rel)

    async_cmd.run_lines(cmd, {
      timeout_ms = 8000,
      progress_key = "git_popup_diff",
      progress_label = "Computing git diff",
    }, function(result)
      if result.code ~= 0 then
        vim.notify("git diff failed for current file", vim.log.levels.ERROR)
        return
      end

      local lines = result.stdout_lines or {}
      if #lines == 0 then
        lines = { "No diff for current file." }
      end

      local cur_win = vim.api.nvim_get_current_win()
      if not cur_win or not vim.api.nvim_win_is_valid(cur_win) then
        cur_win = nil
      end
      local win_w = cur_win and vim.api.nvim_win_get_width(cur_win) or vim.o.columns
      local win_h = cur_win and vim.api.nvim_win_get_height(cur_win) or vim.o.lines
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

      local diff_win
      if cur_win then
        diff_win = vim.api.nvim_open_win(diff_buf, true, {
          relative = "win",
          win = cur_win,
          row = row,
          col = col,
          width = width,
          height = height,
          style = "minimal",
          border = "rounded",
        })
      else
        diff_win = vim.api.nvim_open_win(diff_buf, true, {
          relative = "editor",
          row = math.max(0, math.floor((vim.o.lines - height) / 2)),
          col = math.max(0, math.floor((vim.o.columns - width) / 2)),
          width = width,
          height = height,
          style = "minimal",
          border = "rounded",
        })
      end

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
    end)
  end)

  return true
end

return M
