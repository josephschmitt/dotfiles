-- Center the buffer text within the window by padding both sides with empty
-- buffers, for a focused editing experience on wide monitors.

return {
  "shortcuts/no-neck-pain.nvim",
  cmd = { "NoNeckPain" },
  opts = {
    width = 100,
    buffers = {
      colors = {
        background = "tokyonight-moon",
      },
    },
  },
}
