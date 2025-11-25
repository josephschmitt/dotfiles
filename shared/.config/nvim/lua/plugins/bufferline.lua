return {
  "akinsho/bufferline.nvim",
  opts = {
    options = {
      numbers = "ordinal",
    },
  },
  keys = {
    -- Map Ctrl-0 to go to the last visible buffer
    {
      "<C-0>",
      function()
        local count = #vim.fn.getbufinfo({ buflisted = 1 })
        vim.cmd(("BufferLineGoToBuffer %d"):format(count))
      end,
      mode = { "n", "i", "v" },
      desc = "Go to last buffer",
    },
  },
  config = function(_, opts)
    require("bufferline").setup(opts)
    -- Maps Ctrl-1-9 to go to the Nth visible buffer
    for i = 1, 9 do
      vim.keymap.set({ "n", "i", "v" }, ("<C-%d>"):format(i), ("<Cmd>BufferLineGoToBuffer %d<CR>"):format(i), {
        desc = ("Go to buffer %d"):format(i),
      })
    end
  end,
}
