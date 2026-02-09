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
        -- Top-level shortcuts (single key after leader)
        { "<Leader>c", "<Cmd>bdelete<CR>", desc = "Close buffer" },
        { "<Leader>C", "<Cmd>bdelete!<CR>", desc = "Force close buffer" },
        {
          "<Leader>h",
          function()
            require("snacks").dashboard()
          end,
          desc = "Home Screen",
        },
        { "<Leader>n", "<Cmd>enew<CR>", desc = "New File" },
        { "<Leader>q", "<Cmd>q<CR>", desc = "Quit Window" },
        { "<Leader>Q", "<Cmd>qa<CR>", desc = "Exit Neovim" },
        {
          "<Leader>r",
          function()
            require("snacks").rename.rename_file()
          end,
          desc = "Rename file",
        },
        { "<Leader>s", "<Cmd>w<CR>", desc = "Save buffer" },

        -- Groups
        { "<Leader>b", group = "Buffer", icon = "󰓩" },
        { "<Leader>bs", group = "Sort", icon = "󰒺" },
        { "<Leader>e", group = "Explorer", icon = "󰙅" },
        { "<Leader>f", group = "Find", icon = "󰈞" },
        { "<Leader>g", group = "Git", icon = "󰊢" },
        { "<Leader>gh", group = "Hunk diff", icon = "󰊢" },
        { "<Leader>m", group = "Multicursor", icon = "" },

        { "<Leader><Tab>", group = "Tabs", icon = "󰓩" },
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

        -- Tabs: Vim tab pages (not bufferline tabs)
        { "<Leader><Tab>n", "<Cmd>tabnew<CR>", desc = "New tab" },
        { "<Leader><Tab>c", "<Cmd>tabclose<CR>", desc = "Close tab" },
        { "<Leader><Tab>o", "<Cmd>tabonly<CR>", desc = "Close other tabs" },
        { "<Leader><Tab>]", "<Cmd>tabnext<CR>", desc = "Next tab" },
        { "<Leader><Tab>[", "<Cmd>tabprevious<CR>", desc = "Previous tab" },
        { "<Leader><Tab>l", "<Cmd>tablast<CR>", desc = "Last tab" },
        { "<Leader><Tab>f", "<Cmd>tabfirst<CR>", desc = "First tab" },
        { "<Leader><Tab>>", "<Cmd>+tabmove<CR>", desc = "Move tab right" },
        { "<Leader><Tab><lt>", "<Cmd>-tabmove<CR>", desc = "Move tab left" },
      },
    },
  },
}
