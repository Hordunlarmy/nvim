local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.6"
  },

  -- required for telescope
  "nvim-lua/plenary.nvim",

  {
    'projekt0n/github-nvim-theme',
    config = function()
      require('github-theme').setup({
        -- ...
      })

      vim.cmd('colorscheme github_dark')
    end
  },

  "nvim-treesitter/nvim-treesitter",

  "windwp/nvim-ts-autotag",

  "mbbill/undotree",

  --Devicons
  'kyazdani42/nvim-web-devicons',

  -- LSP Zero
  {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v2.x",
    dependencies = {
      -- LSP Support
      {"neovim/nvim-lspconfig"}, -- Required
      {
        -- Optional
        "williamboman/mason.nvim",
        build = function()
          pcall(vim.cmd, "MasonUpdate")
        end
      },
      {"williamboman/mason-lspconfig.nvim"}, -- Optional
      -- Autocompletion
      {"hrsh7th/nvim-cmp"}, -- Required
      {"hrsh7th/cmp-nvim-lsp"}, -- Required
      {"L3MON4D3/LuaSnip"} -- Required
    }
  },
  -- NULL-LSP
  -- {
    --   "jose-elias-alvarez/null-ls.nvim",
    -- dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    --},

    -- Nvim-lint
    {
      'mfussenegger/nvim-lint',
      'jose-elias-alvarez/nvim-lsp-ts-utils'
    },

    -- Nvim tree
    {
      "nvim-tree/nvim-tree.lua",
      dependencies = {
        "kyazdani42/nvim-web-devicons" -- optional
      }
    },

    "zbirenbaum/copilot.lua",


    -- markdown preview in the browser
    {
      "iamcco/markdown-preview.nvim",
      build = function()
        vim.fn["mkdp#util#install"]()
      end
    },
    -- transparency support in neovim (for adding background image, etc.)
    "xiyaowong/transparent.nvim",

    -- Recent project explorer
    "ahmedkhalf/project.nvim",

    -- show inline git blame
    "f-person/git-blame.nvim",

    -- toggle comments in code
    "numToStr/Comment.nvim",

    -- auto detect indentation
    "nmac427/guess-indent.nvim",

    -- git support in vim
    "tpope/vim-fugitive",

    -- custom status line
    "nvim-lualine/lualine.nvim",

    -- line for showing open buffers in tabline
    -- {'akinsho/bufferline.nvim', version = "*", dependencies = 'kyazdani42/nvim-web-devicons'},
    {
      "willothy/nvim-cokeline",
      dependencies = {
        "nvim-lua/plenary.nvim",        -- Required for v0.4.0+
        "nvim-tree/nvim-web-devicons", -- If you want devicons
        "stevearc/resession.nvim"       -- Optional, for persistent history
      },
      config = true
    },

    -- add highlight matching color to color codes (hex, rgb, etc.)
    {"RRethy/vim-hexokinase", build = "make hexokinase"},


    -- staline status bar
    'tamton-aquib/staline.nvim',

    -- Indentation Line
    { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },

    -- Install Sniprun
    -- { 'michaelb/sniprun', build = 'sh ./install.sh'},

    -- Vim notify
    'rcarriga/nvim-notify',

    -- Autopairs
    {
      "windwp/nvim-autopairs",
      config = function() require("nvim-autopairs").setup {} end
    },
    -- Hover
    {
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
    },

    -- refactoring code-action
    {
      "ThePrimeagen/refactoring.nvim",
      dependencies = {
        {"nvim-lua/plenary.nvim"},
        {"nvim-treesitter/nvim-treesitter"}
      }
    },
    -- vim-doge plugin configuration
    {
      'kkoomen/vim-doge',
      build = ':call doge#install()',  -- Runs the doge installation
      config = function()
        -- Basic vim-doge configuration
        vim.g.doge_enable_mappings = 1    -- Enable default mappings
        vim.g.doge_doc_standard_python = 'google'  -- Set Python docstring style to Google

        -- Additional configurations
        vim.g.doge_mapping = '<Leader>d'  -- Set a custom mapping for documentation
        vim.g.doge_buffer_mappings = 0    -- Disable buffer-specific mappings
        vim.g.doge_comment_style = 'indent' -- Use indented comments
        vim.g.doge_template_file = ''     -- Path to a custom template file (if any)
      end,
    },

    -- Rainmboe delimeter for parenthesis color
    {"hiphish/rainbow-delimiters.nvim"},

    -- Run code from nvim
    'CRAG666/code_runner.nvim',

    -- ALE linter
    --{'dense-analysis/ale'},

    -- util for closing buffers easily
    {"kazhala/close-buffers.nvim"},

    {"mhartington/formatter.nvim"},

    -- Popup Terminal
    {'numToStr/FTerm.nvim'},

  })
