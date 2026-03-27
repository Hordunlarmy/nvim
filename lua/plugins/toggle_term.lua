-- toggleterm: Better terminal integration
return {
  "akinsho/toggleterm.nvim",
  version = "*",
  keys = {
    { "<C-\\>", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
    { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Terminal float" },
    { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Terminal horizontal" },
    { "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", desc = "Terminal vertical" },
  },
  opts = {
    size = function(term)
      if term.direction == "horizontal" then
        return 15
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.4
      end
    end,
    open_mapping = [[<C-\>]],
    hide_numbers = true,
    shade_terminals = true,
    shading_factor = 2,
    start_in_insert = true,
    insert_mappings = true,
    terminal_mappings = true,
    persist_size = true,
    persist_mode = true,
    direction = "float",
    close_on_exit = true,
    shell = vim.o.shell,
    auto_scroll = true,
    float_opts = {
      border = "curved",
      winblend = 0,
      relative = "win",
      width = function()
        return math.max(40, math.floor(vim.api.nvim_win_get_width(0) * 0.9))
      end,
      height = function()
        return math.max(8, math.floor(vim.api.nvim_win_get_height(0) * 0.8))
      end,
      row = function()
        local h = math.max(8, math.floor(vim.api.nvim_win_get_height(0) * 0.8))
        return math.max(0, math.floor((vim.api.nvim_win_get_height(0) - h) / 2))
      end,
      col = function()
        local w = math.max(40, math.floor(vim.api.nvim_win_get_width(0) * 0.9))
        return math.max(0, math.floor((vim.api.nvim_win_get_width(0) - w) / 2))
      end,
      highlights = {
        border = "Normal",
        background = "Normal",
      },
    },
    winbar = {
      enabled = false,
      name_formatter = function(term)
        return term.name
      end,
    },
  },
}

