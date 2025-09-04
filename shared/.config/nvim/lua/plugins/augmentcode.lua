return {
  "augmentcode/augment.vim",
  -- Recommended keymaps from Augment Code documentation
  -- https://docs.augmentcode.com/vim/setup-augment/vim-keyboard-shortcuts
  keys = {
    -- Send a chat message in normal and visual mode
    { "<leader>ac", ":Augment chat<CR>", desc = "Augment: Send chat message", mode = { "n", "v" } },

    -- Start a new chat conversation
    { "<leader>an", ":Augment chat-new<CR>", desc = "Augment: New chat conversation" },

    -- Toggle the chat panel visibility
    { "<leader>at", ":Augment chat-toggle<CR>", desc = "Augment: Toggle chat panel" },

    -- Custom completion acceptance (alternative to Tab)
    -- Use Ctrl-Y to accept a suggestion
    { "<C-y>", "<cmd>call augment#Accept()<cr>", desc = "Augment: Accept suggestion", mode = "i" },

    -- Use Enter to accept a suggestion, falling back to newline if no suggestion
    -- { "<cr>", "<cmd>call augment#Accept(\"\\n\")<cr>", desc = "Augment: Accept suggestion or newline", mode = "i" },
  },
  -- Uncomment the Enter keymap above if you want Enter to accept suggestions
  -- You can also disable the default Tab mapping by setting:
  -- init = function()
  --   vim.g.augment_disable_tab_mapping = true
  -- end,
}
