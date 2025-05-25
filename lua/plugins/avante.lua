local config = function()
  require("avante").setup({
    ---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
    provider = "gemini",
    ---@alias Mode "agentic" | "legacy"
    mode = "agentic",
    auto_suggestions_provider = "gemini",
    gemini = {
      endpoint = "https://generativelanguage.googleapis.com/v1beta/models",
      model = "gemini-2.0-flash",
      timeout = 30000, -- Timeout in milliseconds
      temperature = 0,
      max_tokens = 8192,
    },
    -- provider = "aihubmix",
    -- aihubmix = {
    --   model = "claude-3-5-sonnet-20241022",
    --
    -- }
    dual_boost = {
      enabled = false,
      first_provider = "openai",
      second_provider = "claude",
      prompt = [[
        Based on the two reference outputs below, generate a response that
        incorporates elements from both but reflects your own judgment and
        unique perspective. Do not provide any explanation, just give the
        response directly. Reference Output 1: [{{provider1_output}}],
        Reference Output 2: [{{provider2_output}}]
      ]],
      timeout = 60000,
    },
    behaviour = {
      auto_focus_sidebar = true,
      auto_suggestions = false, -- Experimental stage
      auto_suggestions_respect_ignore = false,
      auto_set_highlight_group = true,
      auto_set_keymaps = true,
      auto_apply_diff_after_generation = false,
      jump_result_buffer_on_finish = false,
      support_paste_from_clipboard = false,
      minimize_diff = true,
      enable_token_counting = true,
      use_cwd_as_project_root = false,
      auto_focus_on_diff_view = false,
    },
    history = {
      max_tokens = 4096,
      carried_entry_count = nil,
      storage_path = vim.fn.stdpath("state") .. "/avante",
      paste = {
        extension = "png",
        filename = "pasted-%Y-%m-%d-%H-%M-%S",
      },
    },
    highlights = {
      diff = {
        current = nil,
        incoming = nil,
      },
    },
    img_paste = {
      url_encode_path = true,
      template = "\nimage: $FILE_PATH\n",
    },
    mappings = {
      ---@class AvanteConflictMappings
      diff = {
        ours = "co",
        theirs = "ct",
        all_theirs = "ca",
        both = "cb",
        cursor = "cc",
        next = "]x",
        prev = "[x",
      },
      suggestion = {
        accept = "<M-l>",
        next = "<M-]>",
        prev = "<M-[>",
        dismiss = "<C-]>",
      },
      jump = {
        next = "]]",
        prev = "[[",
      },
      submit = {
        normal = "<CR>",
        insert = "<C-s>",
      },
      cancel = {
        normal = { "<C-c>", "<Esc>", "q" },
        insert = { "<C-c>" },
      },
      -- NOTE: The following will be safely set by avante.nvim
      ask = "<leader>aa",
      new_ask = "<leader>an",
      edit = "<leader>ae",
      refresh = "<leader>ar",
      focus = "<leader>af",
      stop = "<leader>aS",
      toggle = {
        default = "<leader>at",
        debug = "<leader>ad",
        hint = "<leader>ah",
        suggestion = "<leader>as",
        repomap = "<leader>aR",
      },
      sidebar = {
        apply_all = "A",
        apply_cursor = "a",
        retry_user_request = "r",
        edit_user_request = "e",
        switch_windows = "<Tab>",
        reverse_switch_windows = "<S-Tab>",
        remove_file = "d",
        add_file = "@",
        close = { "q" },
        ---@alias AvanteCloseFromInput { normal: string | nil, insert: string | nil }
        ---@type AvanteCloseFromInput | nil
        close_from_input = nil, -- e.g., { normal = "<Esc>", insert = "<C-d>" }
      },
      files = {
        add_current = "<leader>ac", -- Add current buffer to selected files
        add_all_buffers = "<leader>aB", -- Add all buffer files to selected files
      },
      select_model = "<leader>a?", -- Select model command
      select_history = "<leader>ah", -- Select history command
    },
    windows = {
      ---@alias AvantePosition "right" | "left" | "top" | "bottom" | "smart"
      position = "right",
      fillchars = "eob: ",
      wrap = true, -- similar to vim.o.wrap
      width = 30, -- default % based on available width in vertical layout
      height = 30, -- default % based on available height in horizontal layout
      sidebar_header = {
        enabled = true, -- true, false to enable/disable the header
        align = "center", -- left, center, right for title
        rounded = true,
      },
      input = {
        prefix = "> ",
        height = 8, -- Height of the input window in vertical layout
      },
      edit = {
        border = { " ", " ", " ", " ", " ", " ", " ", " " },
        start_insert = true, -- Start insert mode when opening the edit window
      },
      ask = {
        floating = false, -- Open the 'AvanteAsk' prompt in a floating window
        border = { " ", " ", " ", " ", " ", " ", " ", " " },
        start_insert = true, -- Start insert mode when opening the ask window
        ---@alias AvanteInitialDiff "ours" | "theirs"
        focus_on_apply = "ours", -- which diff to focus after applying
      },
    },
    --- @class AvanteConflictConfig
    diff = {
      autojump = true,
      --- Override the 'timeoutlen' setting while hovering over a diff (see :help timeoutlen).
      --- Helps to avoid entering operator-pending mode with diff mappings starting with `c`.
      --- Disable by setting to -1.
      override_timeoutlen = 500,
    },
    --- @class AvanteHintsConfig
    hints = {
      enabled = false,
    },
    --- @class AvanteRepoMapConfig
    repo_map = {
      ignore_patterns = { "%.git", "%.worktree", "__pycache__", "node_modules", "%.env%" },
      negate_patterns = {}, -- negate ignore files matching these.
    },
    --- @class AvanteFileSelectorConfig
    file_selector = {
      provider = nil,
      -- Options override for custom providers
      provider_opts = {},
    },
    suggestion = {
      debounce = 600,
      throttle = 600,
    },
})
end

return {
  "yetone/avante.nvim",
  config = config,
  event = "VeryLazy",
  version = false,
  build = "make", -- Adjust if you're on Windows
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "echasnovski/mini.pick", -- optional
    "nvim-telescope/telescope.nvim", -- optional
    "hrsh7th/nvim-cmp", -- optional
    "ibhagwan/fzf-lua", -- optional
    "nvim-tree/nvim-web-devicons", -- optional
    "zbirenbaum/copilot.lua", -- optional
    {
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          use_absolute_path = true,
        },
      },
    },
    {
      "MeanderingProgrammer/render-markdown.nvim",
      ft = { "markdown", "Avante" },
      opts = {
        file_types = { "markdown", "Avante" },
      },
    },
  },
}

