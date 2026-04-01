local function get_buffer_plugins(bufnr)
  local ok, lazy_config = pcall(require, "lazy.core.config")
  if not ok or type(lazy_config.plugins) ~= "table" then
    return {}
  end

  local ft = vim.bo[bufnr].filetype
  local matches = {}

  for name, plugin in pairs(lazy_config.plugins) do
    local include = plugin._.loaded ~= nil
    local plugin_ft = plugin.ft

    if not include and plugin_ft and ft and ft ~= "" then
      if type(plugin_ft) == "string" then
        include = plugin_ft == ft
      elseif type(plugin_ft) == "table" then
        include = vim.tbl_contains(plugin_ft, ft)
      end
    end

    if include then
      table.insert(matches, {
        name = name,
        loaded = plugin._.loaded ~= nil,
      })
    end
  end

  table.sort(matches, function(a, b)
    if a.loaded == b.loaded then
      return a.name < b.name
    end
    return a.loaded and not b.loaded
  end)

  return matches
end

local function show_buffer_plugin_info()
  local bufnr = vim.api.nvim_get_current_buf()
  local ft = vim.bo[bufnr].filetype
  local bt = vim.bo[bufnr].buftype
  local filename = vim.api.nvim_buf_get_name(bufnr)

  local lines = {
    "Buffer Plugin Inspector",
    string.rep("=", 24),
    "buffer: " .. bufnr,
    "file: " .. (filename ~= "" and vim.fn.fnamemodify(filename, ":~:.") or "[No Name]"),
    "filetype: " .. (ft ~= "" and ft or "[none]"),
    "buftype: " .. (bt ~= "" and bt or "[none]"),
    "",
    "LSP clients:",
  }

  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  if #clients == 0 then
    table.insert(lines, "- [none]")
  else
    for _, client in ipairs(clients) do
      table.insert(lines, "- " .. client.name)
    end
  end

  table.insert(lines, "")
  table.insert(lines, "Lazy plugins (loaded + filetype-matched):")

  local plugins = get_buffer_plugins(bufnr)
  if #plugins == 0 then
    table.insert(lines, "- [none]")
  else
    for _, item in ipairs(plugins) do
      local marker = item.loaded and "[loaded]" or "[ft]"
      table.insert(lines, "- " .. marker .. " " .. item.name)
    end
  end

  local out = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(out, 0, -1, false, lines)
  vim.bo[out].buftype = "nofile"
  vim.bo[out].bufhidden = "wipe"
  vim.bo[out].swapfile = false
  vim.bo[out].filetype = "markdown"
  vim.bo[out].modifiable = false

  local w = math.max(70, math.floor(vim.o.columns * 0.68))
  local h = math.max(18, math.floor(vim.o.lines * 0.72))
  local row = math.max(1, math.floor((vim.o.lines - h) / 2) - 1)
  local col = math.max(1, math.floor((vim.o.columns - w) / 2))

  local win = vim.api.nvim_open_win(out, true, {
    relative = "editor",
    width = w,
    height = h,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " Buffer Plugin Inspector ",
    title_pos = "center",
  })

  vim.wo[win].wrap = false
  vim.wo[win].cursorline = true
  vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = out, silent = true })
  vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = out, silent = true })
end

vim.api.nvim_create_user_command("BufferPluginInfo", show_buffer_plugin_info, {
  desc = "Show plugin context for current buffer",
})

vim.keymap.set("n", "<leader>uP", show_buffer_plugin_info, {
  desc = "Buffer plugin inspector",
  silent = true,
})
