-- indent-blankline: shows vertical lines at each indentation level.
-- Pairs with mini.indentscope which highlights the active scope.
-- https://github.com/lukas-reineke/indent-blankline.nvim
return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    indent = { char = "│" },
    scope = { enabled = false }, -- Active scope handled by mini.indentscope
  },
}
