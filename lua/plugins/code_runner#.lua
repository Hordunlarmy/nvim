-- Run code from nvim

local config = function()
  require('code_runner').setup({
    mode = 'float', -- Set mode to float
    filetype = {
      java = {
        "cd $dir &&",
        "javac $fileName &&",
        "java $fileNameWithoutExt"
      },
      python = "python3 -u",
      typescript = "deno run",
      javascript = "node",
      rust = {
        "cd $dir &&",
        "rustc $fileName &&",
        "$dir/$fileNameWithoutExt"
      },
    },
    float = {
      border = "double",
      border_hl = "GreenBorder", -- Highlight group for the window border (use your desired highlight group)
    },
  })

  -- Define the GreenBorder highlight group
  vim.cmd([[highlight GreenBorder guifg=#00FF00]])
end

return {
  'CRAG666/code_runner.nvim',
  config = config,
}
