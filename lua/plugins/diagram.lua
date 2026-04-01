-- diagram/image: Mermaid diagrams rendered inside Neovim
return {
  {
    "3rd/image.nvim",
    ft = { "markdown", "norg" },
    opts = function()
      local term = vim.env.TERM or ""
      local has_kitty = (vim.env.KITTY_WINDOW_ID ~= nil and vim.env.KITTY_WINDOW_ID ~= "")
        or term:find("kitty", 1, true) ~= nil
      local has_ueberzug = vim.fn.executable("ueberzug") == 1
      local has_magick = (vim.fn.executable("magick") == 1) or (vim.fn.executable("convert") == 1)

      local backend = "kitty"
      if has_kitty then
        backend = "kitty"
      elseif has_ueberzug then
        backend = "ueberzug"
      end

      return {
        backend = backend,
        processor = "magick_cli",
        integrations = {
          markdown = {
            enabled = has_magick,
            clear_in_insert_mode = false,
            download_remote_images = true,
            only_render_image_at_cursor = false,
            filetypes = { "markdown" },
          },
          neorg = {
            enabled = false,
          },
          html = {
            enabled = false,
          },
          css = {
            enabled = false,
          },
        },
        max_height_window_percentage = 60,
        kitty_method = "normal",
      }
    end,
  },
  {
    "3rd/diagram.nvim",
    ft = { "markdown", "norg" },
    dependencies = { "3rd/image.nvim" },
    keys = {
      {
        "<leader>md",
        function()
          require("diagram").show_diagram_hover()
        end,
        desc = "Mermaid/Diagram Preview",
        ft = { "markdown", "norg" },
      },
    },
    opts = function()
      local ok_markdown, markdown_integration = pcall(require, "diagram.integrations.markdown")
      if not ok_markdown then
        vim.schedule(function()
          vim.notify(
            "diagram.nvim markdown integration is unavailable: " .. tostring(markdown_integration),
            vim.log.levels.ERROR
          )
        end)
        return {
          integrations = {},
        }
      end

      return {
        integrations = {
          markdown_integration,
        },
        events = {
          render_buffer = {},
          clear_buffer = { "BufLeave" },
        },
        renderer_options = {
          mermaid = {
            theme = "dark",
            scale = 2,
          },
        },
      }
    end,
  },
}
