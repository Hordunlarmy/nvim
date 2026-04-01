require("config.suppress_warnings")  -- Must be first to catch all warnings
require("config.env")  -- Clear blocked env vars before plugins initialize
require("config.statusline_guard")
require("config.remap")
require("config.set")
require("config.autocmd")
require("config.borders")
require("config.float_fix")
require("config.padding")
require("config.auto_close")
require("config.fix_luasnip")  -- Adds :LuaSnipRebuild command
require("config.mode_colors")  -- Window separators change color based on mode
require("config.right_padding")  -- Add right margin to main buffer
require("config.buffer_plugin_info")  -- Adds :BufferPluginInfo and <leader>uP
