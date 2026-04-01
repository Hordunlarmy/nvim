local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local clone_cmd = {
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	}
	if type(vim.system) == "function" then
		vim.notify("Bootstrapping lazy.nvim in background. Restart Neovim when complete.", vim.log.levels.INFO)
		vim.system(clone_cmd, { text = true, timeout = 120000 }, function(obj)
			vim.schedule(function()
				if obj.code == 0 then
					vim.notify("lazy.nvim bootstrap complete. Please restart Neovim.", vim.log.levels.INFO)
				else
					local err = (obj.stderr and vim.trim(obj.stderr) ~= "") and vim.trim(obj.stderr) or "git clone failed"
					vim.notify("lazy.nvim bootstrap failed: " .. err, vim.log.levels.ERROR)
				end
			end)
		end)
	else
		vim.notify("lazy.nvim missing. Install it manually to avoid blocking startup.", vim.log.levels.ERROR)
	end
	return
end
vim.opt.rtp:prepend(lazypath)

-- Set localleader for Conjure and other filetype-specific plugins
vim.g.maplocalleader = "\\"

require("config")

local plugins = "plugins"

local opts = {
	defaults = {
		lazy = true,
	},
	install = {
		colorscheme = { "carbonfox" },
	},
	ui = {
		size = { width = 0.85, height = 0.85 },
		border = "rounded",  -- White border
		backdrop = 100,  -- Opaque
	},
	rtp = {
		disabled_plugins = {
			"gzip",
			"matchit",
			"matchparen",
			"netrw",
			"netrwPlugin",
			"tarPlugin",
			"tohtml",
			"tutor",
			"zipPlugin",
		},
	},
	change_detection = {
		notify = false,
	},
	performance = {
		cache = {
			enabled = true,
		},
		reset_packpath = true,
		rtp = {
			reset = true,
			disabled_plugins = {
				"gzip",
				"matchit",
				"matchparen",
				"netrw",
				"netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
	rocks = {
    enabled = false,
    hererocks = false,
  },
}

require("lazy").setup(plugins, opts)

-- Popup colors will be set automatically by borders.lua to match theme
