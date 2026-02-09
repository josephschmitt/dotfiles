-- Customize which-key: use helix-style popup layout and add group icons.
-- which-key shows a popup when you press a key prefix (like <Leader>),
-- listing all available keybindings that follow. Groups organize related
-- bindings under labeled categories with icons.
return {
  {
    "folke/which-key.nvim",
    opts = {
      preset = "helix", -- Centered floating popup (vs default bottom panel)
      spec = {
        { "<Leader>b", group = "Buffer", icon = "󰓩" },
        { "<Leader>bs", group = "Sort", icon = "󰒺" },
        { "<Leader>e", group = "Explorer", icon = "󰙅" },
        { "<Leader>w", group = "Window", icon = "󱂬" },

        -- Window: splits
        { "<Leader>ws", "<Cmd>split<CR>", desc = "Split horizontal" },
        { "<Leader>wv", "<Cmd>vsplit<CR>", desc = "Split vertical" },

        -- Window: closing
        { "<Leader>wc", "<Cmd>close<CR>", desc = "Close window" },
        { "<Leader>wo", "<Cmd>only<CR>", desc = "Close other windows" },

        -- Window: sizing
        { "<Leader>w=", "<C-w>=", desc = "Equalize sizes" },
        { "<Leader>w+", "<Cmd>resize +5<CR>", desc = "Increase height" },
        { "<Leader>w-", "<Cmd>resize -5<CR>", desc = "Decrease height" },
        { "<Leader>w>", "<Cmd>vertical resize +5<CR>", desc = "Increase width" },
        { "<Leader>w<lt>", "<Cmd>vertical resize -5<CR>", desc = "Decrease width" },

        -- Window: movement (reposition current window)
        { "<Leader>wH", "<C-w>H", desc = "Move window left" },
        { "<Leader>wJ", "<C-w>J", desc = "Move window down" },
        { "<Leader>wK", "<C-w>K", desc = "Move window up" },
        { "<Leader>wL", "<C-w>L", desc = "Move window right" },
        { "<Leader>wr", "<C-w>r", desc = "Rotate windows" },
        { "<Leader>wx", "<C-w>x", desc = "Swap with next window" },
      },
    },
  },
}
