-- bufdelete: Delete buffers without closing windows
return {
  "famiu/bufdelete.nvim",
  cmd = { "Bdelete", "Bwipeout" },
  keys = {
    { "<leader>bd", "<cmd>Bdelete<cr>", desc = "Delete buffer" },
    { "<leader>bD", "<cmd>Bdelete!<cr>", desc = "Delete buffer (force)" },
  },
}


