local M = {}

local function clear_progress(key)
  if vim.g.async_progress_enabled ~= true then
    return
  end
  local ok_progress, progress = pcall(require, "util.progress")
  if ok_progress and progress and type(progress.clear_manual) == "function" then
    pcall(progress.clear_manual, key)
  end
end

local function set_progress(label, key)
  if vim.g.async_progress_enabled ~= true then
    return
  end
  local ok_progress, progress = pcall(require, "util.progress")
  if ok_progress and progress and type(progress.set_manual) == "function" then
    pcall(progress.set_manual, label, key)
  end
end

local function split_lines(text)
  if type(text) ~= "string" or text == "" then
    return {}
  end
  local lines = vim.split(text, "\n", { plain = true })
  if #lines > 0 and lines[#lines] == "" then
    table.remove(lines, #lines)
  end
  return lines
end

---Run a shell command asynchronously and return output in callback.
---@param cmd string[]
---@param opts table|nil
---@param cb fun(result: {code: integer, signal: integer, stdout: string, stderr: string})
function M.run(cmd, opts, cb)
  opts = opts or {}
  local key = opts.progress_key
  if key and opts.progress_label then
    set_progress(opts.progress_label, key)
  end

  local function done(result)
    if key then
      clear_progress(key)
    end
    vim.schedule(function()
      cb(result)
    end)
  end

  if type(vim.system) == "function" then
    local ok = pcall(vim.system, cmd, {
      text = true,
      cwd = opts.cwd,
      timeout = opts.timeout_ms,
      env = opts.env,
    }, function(obj)
      done({
        code = obj.code or 1,
        signal = obj.signal or 0,
        stdout = obj.stdout or "",
        stderr = obj.stderr or "",
      })
    end)
    if ok then
      return
    end
  end

  -- Fallback for older Neovim versions.
  local out = {}
  local err = {}
  local job_id = vim.fn.jobstart(cmd, {
    cwd = opts.cwd,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if type(data) == "table" then
        out = data
      end
    end,
    on_stderr = function(_, data)
      if type(data) == "table" then
        err = data
      end
    end,
    on_exit = function(_, code, signal)
      done({
        code = code or 1,
        signal = signal or 0,
        stdout = table.concat(out or {}, "\n"),
        stderr = table.concat(err or {}, "\n"),
      })
    end,
  })

  if job_id <= 0 then
    done({
      code = 1,
      signal = 0,
      stdout = "",
      stderr = "Failed to start async command",
    })
  end
end

---@param cmd string[]
---@param opts table|nil
---@param cb fun(result: {code: integer, signal: integer, stdout: string, stderr: string, stdout_lines: string[], stderr_lines: string[]})
function M.run_lines(cmd, opts, cb)
  M.run(cmd, opts, function(result)
    result.stdout_lines = split_lines(result.stdout)
    result.stderr_lines = split_lines(result.stderr)
    cb(result)
  end)
end

return M
