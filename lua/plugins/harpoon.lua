-- harpoon: quick file navigation and marking
return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    {
      "<leader>ha",
      function()
        require("harpoon"):list():add()
        vim.notify("File added to Harpoon", vim.log.levels.INFO)
      end,
      desc = "Harpoon: Add file",
    },
    {
      "<leader>hh",
      function()
        local harpoon = require("harpoon")
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end,
      desc = "Harpoon: Quick menu",
    },
    {
      "<leader>h1",
      function()
        require("harpoon"):list():select(1)
      end,
      desc = "Harpoon: File 1",
    },
    {
      "<leader>h2",
      function()
        require("harpoon"):list():select(2)
      end,
      desc = "Harpoon: File 2",
    },
    {
      "<leader>h3",
      function()
        require("harpoon"):list():select(3)
      end,
      desc = "Harpoon: File 3",
    },
    {
      "<leader>h4",
      function()
        require("harpoon"):list():select(4)
      end,
      desc = "Harpoon: File 4",
    },
    {
      "<leader>hn",
      function()
        require("harpoon"):list():next()
      end,
      desc = "Harpoon: Next file",
    },
    {
      "<leader>hp",
      function()
        require("harpoon"):list():prev()
      end,
      desc = "Harpoon: Previous file",
    },
    {
      "<leader>hr",
      function()
        require("harpoon"):list():remove()
        vim.notify("File removed from Harpoon", vim.log.levels.INFO)
      end,
      desc = "Harpoon: Remove current file",
    },
    {
      "<leader>hc",
      function()
        require("harpoon"):list():clear()
        vim.notify("Harpoon list cleared!", vim.log.levels.WARN)
      end,
      desc = "Harpoon: Clear all files",
    },
  },
  config = function()
    require("harpoon"):setup({
      settings = {
        save_on_toggle = true,
        sync_on_ui_close = true,
      },
    })
  end,
}


