-- Bufferline: shows open buffers as tabs at the top of the editor.
-- Each tab shows the filename with an ordinal number (1, 2, 3...),
-- and you can jump to any buffer with Ctrl+1-9 or navigate with Shift+h/l.
-- https://github.com/akinsho/bufferline.nvim
return {
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "BufAdd",
    opts = {
      options = {
        always_show_bufferline = false, -- Hide when only one buffer is open (e.g. dashboard)
        numbers = "ordinal", -- Show 1, 2, 3... on each tab
        diagnostics = "nvim_lsp", -- Show LSP error/warning indicators on tabs
        offsets = {
          { filetype = "neo-tree", text = "Explorer", highlight = "Directory", separator = true },
        },
      },
    },
    config = function(_, opts)
      require("bufferline").setup(opts)

      -- Ctrl+1-9 to jump directly to buffer by ordinal number
      for i = 1, 9 do
        vim.keymap.set({ "n", "i", "v" }, ("<C-%d>"):format(i), ("<Cmd>BufferLineGoToBuffer %d<CR>"):format(i), {
          desc = ("Go to buffer %d"):format(i),
        })
      end
    end,
    keys = {
      -- Navigate between buffers
      { "<S-h>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Previous buffer" },
      { "<S-l>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },

      -- Buffer selection
      { "<Leader>bb", "<Cmd>BufferLinePick<CR>", desc = "Select buffer from tabline" },
      { "<Leader>bp", "<Cmd>BufferLineCyclePrev<CR>", desc = "Previous buffer" },

      -- Close buffers
      { "<Leader>ba", "<Cmd>BufferLineCloseOthers<CR><Cmd>bdelete<CR>", desc = "Close all buffers" },
      { "<Leader>bc", "<Cmd>BufferLineCloseOthers<CR>", desc = "Close all except current" },
      { "<Leader>bC", "<Cmd>BufferLineCloseOthers<CR><Cmd>bdelete<CR>", desc = "Close all buffers" },
      { "<Leader>bd", "<Cmd>BufferLinePickClose<CR>", desc = "Close buffer from tabline" },
      { "<Leader>bD", "<Cmd>bdelete<CR>", desc = "Close current buffer" },
      { "<Leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Close all to the left" },
      { "<Leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Close all to the right" },

      -- Split from tabline (pick a buffer, open in split)
      { "<Leader>b\\", "<Cmd>BufferLinePick<CR><Cmd>split<CR>", desc = "Horizontal split from tabline" },
      { "<Leader>b|", "<Cmd>BufferLinePick<CR><Cmd>vsplit<CR>", desc = "Vertical split from tabline" },

      -- Sort buffers (group label defined in which-key.lua)
      { "<Leader>bse", "<Cmd>BufferLineSortByExtension<CR>", desc = "Sort by extension" },
      { "<Leader>bsd", "<Cmd>BufferLineSortByDirectory<CR>", desc = "Sort by directory" },

      -- Jump to last buffer with Ctrl+0
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
  },
}
