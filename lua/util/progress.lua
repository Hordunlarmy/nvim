local M = {}

local frames = { "◴", "◷", "◶", "◵" }

local setup_done = false
local tick = nil
local lsp_progress_handler_patched = false

local lazy_busy = false
local lazy_started_at = nil
local manual_state = {}
local lsp_progress_tokens = {}
local lsp_pending_requests = {}

local STALE_TOKEN_MS = 10000
local STALE_REQUEST_MS = 6000
local VISIBILITY_DELAY_MS = 250

local function now_ms()
  return math.floor(vim.uv.hrtime() / 1e6)
end

local function spinner()
  local i = math.floor(vim.uv.hrtime() / 1e8) % #frames + 1
  return frames[i]
end

local function clamp(value, min_v, max_v)
  return math.max(min_v, math.min(max_v, value))
end

local function compact(text, max_len)
  if #text <= max_len then
    return text
  end
  return text:sub(1, max_len - 3) .. "..."
end

local function marquee(text, width)
  if #text <= width then
    return text
  end
  local gap = "   "
  local loop = text .. gap
  local n = #loop
  local start = (math.floor(vim.uv.hrtime() / 1.2e8) % n) + 1
  local piece = loop:sub(start, start + width - 1)
  if #piece < width then
    piece = piece .. loop:sub(1, width - #piece)
  end
  return piece
end

local function parse_percent(text)
  if type(text) ~= "string" or text == "" then
    return nil
  end
  local p = text:match("(%d?%d?%d)%%")
  if not p then
    return nil
  end
  p = tonumber(p)
  if not p then
    return nil
  end
  return clamp(p, 0, 100)
end

local function normalize_percentage(value)
  if type(value) == "number" then
    return clamp(math.floor(value), 0, 100)
  end
  if type(value) == "string" then
    return parse_percent(value)
  end
  return nil
end

local function sanitize_text(text)
  if type(text) ~= "string" then
    return "Loading"
  end
  text = text:gsub("[%z\1-\8\11\12\14-\31\127]", " ")
  text = vim.trim(text:gsub("%s+", " "))
  return text ~= "" and text or "Loading"
end

local function serialize_token(value, seen)
  local t = type(value)
  if t == "nil" then
    return "nil"
  end
  if t == "string" then
    return "s:" .. value
  end
  if t == "number" then
    return "n:" .. tostring(value)
  end
  if t == "boolean" then
    return value and "b:1" or "b:0"
  end
  if t ~= "table" then
    return "x:" .. tostring(value)
  end

  seen = seen or {}
  if seen[value] then
    return "cycle"
  end
  seen[value] = true

  if vim.islist(value) then
    local parts = {}
    for i = 1, #value do
      parts[#parts + 1] = serialize_token(value[i], seen)
    end
    return "l:[" .. table.concat(parts, ",") .. "]"
  end

  local keys = {}
  for k, _ in pairs(value) do
    keys[#keys + 1] = { key = k, sort = tostring(k) }
  end
  table.sort(keys, function(a, b)
    return a.sort < b.sort
  end)

  local parts = {}
  for _, item in ipairs(keys) do
    parts[#parts + 1] = item.sort .. "=" .. serialize_token(value[item.key], seen)
  end
  return "m:{" .. table.concat(parts, ",") .. "}"
end

local function token_key(client_id, token)
  if client_id == nil then
    return nil
  end
  if token == nil then
    return tostring(client_id) .. ":__anonymous"
  end
  return tostring(client_id) .. ":" .. serialize_token(token)
end

local function request_key(client_id, request_id)
  if client_id == nil or request_id == nil then
    return nil
  end
  return tostring(client_id) .. ":" .. tostring(request_id)
end

local function track_lsp_progress(client_id, params, kind_override)
  if type(params) ~= "table" then
    return
  end
  local value = params.value
  if type(value) ~= "table" then
    return
  end

  local key = token_key(client_id, params.token)
  if not key then
    return
  end

  local kind = type(kind_override) == "string" and kind_override ~= "" and kind_override or tostring(value.kind or "")
  if kind == "end" then
    lsp_progress_tokens[key] = nil
    return
  end

  local existing = lsp_progress_tokens[key]
  lsp_progress_tokens[key] = {
    method = "$/progress",
    title = sanitize_text(value.title or ""),
    message = sanitize_text(value.message or ""),
    percentage = normalize_percentage(value.percentage),
    started_at = (existing and existing.started_at) or now_ms(),
    updated_at = now_ms(),
  }
end

local function short_method(method)
  if type(method) ~= "string" or method == "" then
    return "LSP request"
  end
  method = method:gsub("^textDocument/", "")
  method = method:gsub("^workspace/", "")
  return method
end

local function purge_stale_tokens()
  local cutoff = now_ms() - STALE_TOKEN_MS
  local changed = false
  for key, item in pairs(lsp_progress_tokens) do
    if type(item) ~= "table" or (item.updated_at or 0) < cutoff then
      lsp_progress_tokens[key] = nil
      changed = true
    end
  end
  return changed
end

local function purge_stale_requests()
  local cutoff = now_ms() - STALE_REQUEST_MS
  local changed = false
  for key, item in pairs(lsp_pending_requests) do
    if type(item) ~= "table" or (item.updated_at or 0) < cutoff then
      lsp_pending_requests[key] = nil
      changed = true
    end
  end
  return changed
end

local function clear_client_state(client_id)
  if client_id == nil then
    return
  end
  local prefix = tostring(client_id) .. ":"
  for key, _ in pairs(lsp_progress_tokens) do
    if key:sub(1, #prefix) == prefix then
      lsp_progress_tokens[key] = nil
    end
  end
  for key, _ in pairs(lsp_pending_requests) do
    if key:sub(1, #prefix) == prefix then
      lsp_pending_requests[key] = nil
    end
  end
end

local function latest_matching_entry(tbl, predicate)
  local latest = nil
  for _, item in pairs(tbl) do
    if predicate(item) and (not latest or (item.updated_at or 0) > (latest.updated_at or 0)) then
      latest = item
    end
  end
  return latest
end

local function age_ms(entry)
  if type(entry) ~= "table" then
    return 0
  end
  local started = entry.started_at or entry.updated_at
  if type(started) ~= "number" then
    return 0
  end
  return math.max(0, now_ms() - started)
end

local function is_visible(entry)
  return age_ms(entry) >= VISIBILITY_DELAY_MS
end

local function has_manual()
  return next(manual_state) ~= nil
end

local function has_lsp_activity()
  purge_stale_tokens()
  purge_stale_requests()
  return next(lsp_progress_tokens) ~= nil or next(lsp_pending_requests) ~= nil
end

local function status_snapshot()
  local manual_entry = nil
  if manual_state.reload then
    manual_entry = manual_state.reload
  else
    for _, entry in pairs(manual_state) do
      manual_entry = entry
      break
    end
  end

  if manual_entry and is_visible(manual_entry) then
    local pct = nil
    if manual_entry.duration_ms and manual_entry.duration_ms > 0 and manual_entry.started_at then
      pct = clamp(math.floor(((now_ms() - manual_entry.started_at) / manual_entry.duration_ms) * 100), 0, 95)
    end
    return true, sanitize_text(manual_entry.label or "Loading"), pct
  end

  purge_stale_tokens()
  local token = latest_matching_entry(lsp_progress_tokens, is_visible)
  if token then
    local pieces = {}
    if token.title and token.title ~= "" and token.title ~= "Loading" then
      pieces[#pieces + 1] = token.title
    end
    if token.message and token.message ~= "" and token.message ~= "Loading" then
      pieces[#pieces + 1] = token.message
    end
    local label = #pieces > 0 and table.concat(pieces, " - ") or "LSP loading"
    return true, compact(sanitize_text(label), 44), token.percentage
  end

  purge_stale_requests()
  local req = latest_matching_entry(lsp_pending_requests, is_visible)
  if req then
    return true, compact("LSP " .. short_method(req.method), 44), nil
  end

  if lazy_busy and lazy_started_at and (now_ms() - lazy_started_at) >= VISIBILITY_DELAY_MS then
    return true, "Loading plugins", nil
  end

  return false, "", nil
end

local function redraw()
  pcall(vim.cmd, "redrawstatus")
end

local function apply_busy_state()
  local active = lazy_busy or has_lsp_activity() or has_manual()
  if active and tick == nil then
    tick = vim.uv.new_timer()
    if tick then
      tick:start(0, 120, vim.schedule_wrap(function()
        local still_active = lazy_busy or has_lsp_activity() or has_manual()
        if not still_active and tick then
          tick:stop()
          tick:close()
          tick = nil
        end
        redraw()
      end))
    end
  elseif (not active) and tick then
    tick:stop()
    tick:close()
    tick = nil
  end
  redraw()
end

function M.set_manual(label, key, opts)
  key = key or "manual"
  opts = opts or {}
  manual_state[key] = {
    label = sanitize_text((type(label) == "string" and label ~= "") and label or "Loading"),
    started_at = now_ms(),
    duration_ms = type(opts.duration_ms) == "number" and opts.duration_ms or nil,
  }
  apply_busy_state()
end

function M.clear_manual(key)
  if key then
    manual_state[key] = nil
  else
    manual_state = {}
  end
  apply_busy_state()
end

function M.is_busy()
  local busy = status_snapshot()
  return busy
end

function M.setup()
  if setup_done then
    return
  end
  setup_done = true

  if not lsp_progress_handler_patched then
    lsp_progress_handler_patched = true
    local raw_progress_handler = vim.lsp.handlers["$/progress"]
    vim.lsp.handlers["$/progress"] = function(err, result, ctx, config)
      track_lsp_progress(ctx and ctx.client_id or nil, result, nil)
      apply_busy_state()
      if type(raw_progress_handler) == "function" then
        return raw_progress_handler(err, result, ctx, config)
      end
    end
  end

  local group = vim.api.nvim_create_augroup("StatusProgressBar", { clear = true })

  vim.api.nvim_create_autocmd("LspProgress", {
    group = group,
    callback = function(args)
      local data = args and args.data or nil
      local params = data and data.params or nil
      local client_id = data and data.client_id or nil
      track_lsp_progress(client_id, params, args and args.match or nil)
      apply_busy_state()
    end,
  })

  vim.api.nvim_create_autocmd("LspRequest", {
    group = group,
    callback = function(args)
      local data = args and args.data or nil
      local client_id = data and data.client_id or nil
      local request_id = data and data.request_id or nil
      local request = data and data.request or nil
      local req_type = type(request) == "table" and request.type or nil
      local method = type(request) == "table" and request.method or nil
      local key = request_key(client_id, request_id)

      if key and req_type == "pending" then
        local existing = lsp_pending_requests[key]
        lsp_pending_requests[key] = {
          method = method or "request",
          started_at = (existing and existing.started_at) or now_ms(),
          updated_at = now_ms(),
        }
      elseif key and (req_type == "complete" or req_type == "cancel") then
        lsp_pending_requests[key] = nil
      end

      apply_busy_state()
    end,
  })

  vim.api.nvim_create_autocmd("LspDetach", {
    group = group,
    callback = function(args)
      local client_id = args and args.data and args.data.client_id or nil
      clear_client_state(client_id)
      apply_busy_state()
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = {
      "LazySyncPre",
      "LazyInstallPre",
      "LazyUpdatePre",
      "LazyCheckPre",
      "LazyCleanPre",
    },
    callback = function()
      lazy_busy = true
      lazy_started_at = lazy_started_at or now_ms()
      apply_busy_state()
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = { "LazyDone", "LazySync", "LazyInstall", "LazyUpdate", "LazyCheck", "LazyClean" },
    callback = function()
      lazy_busy = false
      lazy_started_at = nil
      apply_busy_state()
    end,
  })
end

function M.component()
  local busy, label, pct = status_snapshot()
  if not busy then
    return ""
  end

  local pct_text = pct and string.format(" %d%%", pct) or ""
  local text = string.format("Loading: %s%s", sanitize_text(label), pct_text)
  return marquee(text, math.max(24, math.floor(vim.o.columns * 0.22)))
end

function M.fullwidth_component()
  local busy, label, pct = status_snapshot()
  if not busy then
    return ""
  end
  local pct_text = pct and string.format(" %d%%", pct) or ""
  local text = string.format("Loading: %s%s", sanitize_text(label), pct_text)
  return marquee(text, math.max(32, math.floor(vim.o.columns * 0.34)))
end

function M.icon_component()
  local busy = status_snapshot()
  if not busy then
    return ""
  end
  return spinner()
end

return M
