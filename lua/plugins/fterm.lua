-- Popup Terminal

local config = function()
  require 'FTerm'.setup({
    border = 'double',

    ---Filetype of the terminal buffer
    ---@type string
    ft = 'FTerm',

    ---Command to run inside the terminal
    ---NOTE: if given string[], it will skip the shell and directly executes the command
    ---@type fun():(string|string[])|string|string[]
    cmd = os.getenv('SHELL'),

    ---Neovim's native window border. See `:h nvim_open_win` for more configuration options.
    -- border = { "╔", "═", "╗", "║", "╝", "═", "╚", "║" },

    ---Close the terminal as soon as shell/command exits.
    ---Disabling this will mimic the native terminal behaviour.
    ---@type boolean
    auto_close = true,

    ---Highlight group for the terminal. See `:h winhl`
    ---@type string
    hl = 'Normal',

    ---Transparency of the floating window. See `:h winblend`
    ---@type integer
    blend = 0,

    ---Object containing the terminal window dimensions.
    ---The value for each field should be between `0` and `1`
    ---@type table<string,number>
    dimensions = {
      height = 0.8, -- Height of the terminal window
      width = 0.8,  -- Width of the terminal window
      x = 0.5,      -- X axis of the terminal window
      y = 0.5,      -- Y axis of the terminal window
    },

    ---Replace instead of extend the current environment with `env`.
    ---See `:h jobstart-options`
    ---@type boolean
    clear_env = false,

    ---Map of environment variables extending the current environment.
    ---See `:h jobstart-options`
    ---@type table<string,string>|nil
    env = nil,

    ---Callback invoked when the terminal exits.
    ---See `:h jobstart-options`
    ---@type fun()|nil
    on_exit = nil,

    ---Callback invoked when the terminal emits stdout data.
    ---See `:h jobstart-options`
    ---@type fun()|nil
    on_stdout = nil,

    ---Callback invoked when the terminal emits stderr data.
    ---See `:h jobstart-options`
    ---@type fun()|nil
    on_stderr = nil,
  })

  -- Key mapping to open the terminal popup
  vim.api.nvim_set_keymap('n', '<leader>t', ':lua OpenTerminalPopup()<CR>', { noremap = true, silent = true })

  -- Open Terminal
  vim.api.nvim_create_user_command('FTermOpen', require('FTerm').open, { bang = true })
  vim.api.nvim_set_keymap('n', '<leader>t', ':FTermOpen<CR>', { noremap = true, silent = true })

  -- Close terminal popup
  vim.api.nvim_create_user_command('FTermClose', require('FTerm').close, { bang = true })
  vim.api.nvim_set_keymap('t', '<Esc>', '<C-\\><C-n>:FTermClose<CR>', { noremap = true, silent = true })

  -- Exit terminal
  vim.api.nvim_create_user_command('FTermExit', require('FTerm').exit, { bang = true })
  vim.api.nvim_set_keymap('t', '<leader>q', '<C-\\><C-n>:FTermClose<CR>', { noremap = true, silent = true })

  -- Define the GreenBorder highlight group
  vim.cmd([[highlight GreenBorder guifg=#00FF00]])
end

return {
  'numToStr/FTerm.nvim',
  config = config,
}
