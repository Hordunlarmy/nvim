-- Autocompletion plugin for neovim

return {
	"hrsh7th/nvim-cmp",
	config = function()
		local cmp = require("cmp")
		local luasnip = require("luasnip")
		local lspkind = require("lspkind")

		require("luasnip/loaders/from_vscode")

		vim.opt.completeopt = "menu,menuone,noselect"

		local cmp_enabled = false

		cmp.setup({
			enabled = function()
				return cmp_enabled
			end,
			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},
			window = {
				completion = cmp.config.window.bordered(),
				documentation = cmp.config.window.bordered(),
			},
			mapping = cmp.mapping.preset.insert({
				["<C-k>"] = cmp.mapping.select_prev_item(),
				["<C-j>"] = cmp.mapping.select_next_item(),
				["<C-b>"] = cmp.mapping.scroll_docs(-4),
				["<C-f>"] = cmp.mapping.scroll_docs(4),
				["<C-Space>"] = cmp.mapping.complete(),
				["<C-e>"] = cmp.mapping.abort(),
				["<CR>"] = cmp.mapping.confirm({ select = false }),
			}),
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "luasnip" },
				{ name = "buffer" },
				{ name = "path" },
			}),
			formatting = {
				format = lspkind.cmp_format({
					maxwidth = 50,
					ellipsis_char = "...",
				}),
			},
		})

		vim.keymap.set("n", "<leader>ce", function()
			cmp_enabled = not cmp_enabled
			vim.notify("nvim-cmp " .. (cmp_enabled and "enabled" or "disabled"))
		end, { silent = true, desc = "Toggle nvim-cmp" })
	end,
	dependencies = {
		"onsails/lspkind.nvim",
		{
			"L3MON4D3/LuaSnip",
			version = "2.*",
			build = "make install_jsregexp",
		},
	},
}
