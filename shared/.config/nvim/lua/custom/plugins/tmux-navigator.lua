-- vim-tmux-navigator: seamless navigation between Neovim splits and tmux panes.
-- Overrides <C-h/j/k/l> from init.lua to work across both Neovim and tmux.
-- https://github.com/christoomey/vim-tmux-navigator
return {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
  },
  keys = {
    { "<C-h>", "<Cmd>TmuxNavigateLeft<CR>", desc = "Navigate left (tmux-aware)" },
    { "<C-j>", "<Cmd>TmuxNavigateDown<CR>", desc = "Navigate down (tmux-aware)" },
    { "<C-k>", "<Cmd>TmuxNavigateUp<CR>", desc = "Navigate up (tmux-aware)" },
    { "<C-l>", "<Cmd>TmuxNavigateRight<CR>", desc = "Navigate right (tmux-aware)" },
    { "<C-\\>", "<Cmd>TmuxNavigatePrevious<CR>", desc = "Navigate previous (tmux-aware)" },
  },
}
