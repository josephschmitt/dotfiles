-- ~/.config/nvim/lua/plugins/textobj-fold.lua
return {
  {
    -- Change the repository URL to the fork
    "somini/vim-textobj-fold",
    -- Ensure the dependency is loaded first by lazy.nvim
    dependencies = { "kana/vim-textobj-user" },
    -- Load the plugin lazily
    event = "VeryLazy",
    keys = {
      -- Define the 'z' prefix group for which-key plugin description
      { "z", group = "Fold Textobj (somini fork)" }, -- Updated group name slightly
      -- Map 'zi' in visual ('x') and operator-pending ('o') modes
      { "zi", "<Plug>(textobj-fold-i)", mode = { "x", "o" }, desc = "Inside Fold (Strict)" }, -- Updated desc
      -- Map 'za' in visual ('x') and operator-pending ('o') modes
      { "za", "<Plug>(textobj-fold-a)", mode = { "x", "o" }, desc = "Around Fold" },
    },
  },
  -- kana/vim-textobj-user dependency is handled automatically
}
