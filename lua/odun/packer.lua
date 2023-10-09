-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require("packer").startup(
    function(use)
        -- Packer can manage itself
        use "wbthomason/packer.nvim"

        use {
            "nvim-telescope/telescope.nvim",
            tag = "0.1.1"
        }

        -- required for telescope
        use("nvim-lua/plenary.nvim")

        use({
            'projekt0n/github-nvim-theme',
            config = function()
                require('github-theme').setup({
                    -- ...
                })

                vim.cmd('colorscheme github_dark')
            end
        })

        use("nvim-treesitter/nvim-treesitter", {run = ":TSUpdate"})

        use("windwp/nvim-ts-autotag")

        use("mbbill/undotree")

        -- LSP Zero
        use {
            "VonHeikemen/lsp-zero.nvim",
            branch = "v2.x",
            requires = {
                -- LSP Support
                {"neovim/nvim-lspconfig"}, -- Required
                {
                    -- Optional
                    "williamboman/mason.nvim",
                    run = function()
                        pcall(vim.cmd, "MasonUpdate")
                    end
                },
                {"williamboman/mason-lspconfig.nvim"}, -- Optional
                -- Autocompletion
                {"hrsh7th/nvim-cmp"}, -- Required
                {"hrsh7th/cmp-nvim-lsp"}, -- Required
                {"L3MON4D3/LuaSnip"} -- Required
            }
        }
        -- NULL-LSP
       -- use {
         --   "jose-elias-alvarez/null-ls.nvim",
           -- requires = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
        --}

        -- Nvim-lint
        use 'mfussenegger/nvim-lint'

        -- Nvim tree
        use {
            "nvim-tree/nvim-tree.lua",
            requires = {
                "nvim-tree/nvim-web-devicons" -- optional
            }
        }

        use("zbirenbaum/copilot.lua")

        use("theprimeagen/Vim-be-good")

        -- markdown preview in the browser
        use(
        {
            "iamcco/markdown-preview.nvim",
            run = function()
                vim.fn["mkdp#util#install"]()
            end
        }
        )
        -- transparency support in neovim (for adding background image, etc.)
        use("xiyaowong/transparent.nvim")

        -- Recent project explorer
        use("ahmedkhalf/project.nvim")

        -- show inline git blame
        use("f-person/git-blame.nvim")

        -- toggle comments in code
        use("numToStr/Comment.nvim")

        -- auto detect indentation
        use("nmac427/guess-indent.nvim")

        -- git support in vim
        use("tpope/vim-fugitive")

        -- custom status line
        -- use {"nvim-lualine/lualine.nvim"}

        -- line for showing open buffers in tabline
        use {"akinsho/bufferline.nvim", tag = "*"}

        -- add highlight matching color to color codes (hex, rgb, etc.)
        use {"RRethy/vim-hexokinase", run = "make hexokinase"}

        --Devicons
        use 'kyazdani42/nvim-web-devicons'

        -- staline status bar
        use 'tamton-aquib/staline.nvim'

        -- Indentation Line
        use {
            'lukas-reineke/indent-blankline.nvim',
            tag = 'v2.0.0'
        }

        -- Install Sniprun
        use { 'michaelb/sniprun', run = 'sh ./install.sh'}

        -- Vim notify
        use 'rcarriga/nvim-notify'

        -- Autopairs
        use {
            "windwp/nvim-autopairs",
            config = function() require("nvim-autopairs").setup {} end
        }
        -- Hover
        use {
            "lewis6991/hover.nvim",
            config = function()
                require("hover").setup {
                    init = function()
                        -- Require providers
                        require("hover.providers.lsp")
                        -- require('hover.providers.gh')
                        -- require('hover.providers.gh_user')
                        -- require('hover.providers.jira')
                        require('hover.providers.man')
                        -- require('hover.providers.dictionary')
                    end,
                    preview_opts = {
                        border = nil
                    },
                    -- Whether the contents of a currently open hover window should be moved
                    -- to a :h preview-window when pressing the hover keymap.
                    preview_window = false,
                    title = true
                }

                -- Setup keymaps
                vim.keymap.set("n", "K", require("hover").hover, {desc = "hover.nvim"})
                vim.keymap.set("n", "gK", require("hover").hover_select, {desc = "hover.nvim (select)"})
            end
        }
        -- refactoring code-action
        use {
            "ThePrimeagen/refactoring.nvim",
            requires = {
                {"nvim-lua/plenary.nvim"},
                {"nvim-treesitter/nvim-treesitter"}
            }
        }
        -- Rainmboe delimeter for parenthesis color
        use {"hiphish/rainbow-delimiters.nvim"}

        -- Run code from nvim
        use 'CRAG666/code_runner.nvim'

        -- ALE linter
        --use {'dense-analysis/ale'}

        -- util for closing buffers easily
        use {"kazhala/close-buffers.nvim"}

        use {"mhartington/formatter.nvim"}
    end
    )
