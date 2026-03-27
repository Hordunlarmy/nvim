-- Set popup backgrounds to match theme with WHITE BORDERS

local function get_normal_bg()
  local hl = vim.api.nvim_get_hl(0, { name = "Normal" })
  if hl.bg then
    return string.format("#%06x", hl.bg)
  end
  return "NONE"
end

local function set_float_colors()
  local bg = get_normal_bg()
  local bg_opt = (bg == "NONE") and {} or { bg = bg }
  local border_fg = { fg = "#ffffff" }
  local border = vim.tbl_extend("force", border_fg, bg_opt)

  -- Core float highlights
  vim.api.nvim_set_hl(0, "FloatBorder", border)
  vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" })
  vim.api.nvim_set_hl(0, "FloatTitle", border)

  -- Telescope
  vim.api.nvim_set_hl(0, "TelescopeBorder", border)
  vim.api.nvim_set_hl(0, "TelescopePromptBorder", border)
  vim.api.nvim_set_hl(0, "TelescopeResultsBorder", border)
  vim.api.nvim_set_hl(0, "TelescopePreviewBorder", border)
  vim.api.nvim_set_hl(0, "TelescopeNormal", { link = "Normal" })
  vim.api.nvim_set_hl(0, "TelescopePromptNormal", { link = "Normal" })
  vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { link = "Normal" })
  vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { link = "Normal" })

  -- Which-Key
  vim.api.nvim_set_hl(0, "WhichKeyBorder", border)
  vim.api.nvim_set_hl(0, "WhichKeyFloat", { link = "Normal" })

  -- Lazy
  vim.api.nvim_set_hl(0, "LazyNormal", { link = "Normal" })
  vim.api.nvim_set_hl(0, "LazyFloat", { link = "Normal" })
  vim.api.nvim_set_hl(0, "LazyFloatBorder", border)

  -- Mason
  vim.api.nvim_set_hl(0, "MasonNormal", { link = "Normal" })
  vim.api.nvim_set_hl(0, "MasonFloat", { link = "Normal" })

  -- LSP / diagnostics
  vim.api.nvim_set_hl(0, "LspInfoBorder", border)
  vim.api.nvim_set_hl(0, "DiagnosticFloatingBorder", border)

  -- Lspsaga
  vim.api.nvim_set_hl(0, "SagaBorder", border)
  vim.api.nvim_set_hl(0, "SagaNormal", { link = "Normal" })

  -- Conjure
  vim.api.nvim_set_hl(0, "ConjureLogHudBorder", border)
  vim.api.nvim_set_hl(0, "ConjureLogHudNormal", { link = "Normal" })
end

set_float_colors()

local border_augroup = vim.api.nvim_create_augroup("BorderColors", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
  group = border_augroup,
  pattern = "*",
  callback = set_float_colors,
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = border_augroup,
  pattern = "*",
  callback = function()
    vim.defer_fn(set_float_colors, 200)
  end,
})

-- Global diagnostic float border
vim.diagnostic.config({
  float = {
    border = "rounded",
  },
})

return {}
