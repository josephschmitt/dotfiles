-- return {
--   "cousine/opencode-context.nvim",
--   opts = {
--     -- tmux_target = nil, -- Manual override: "session:window.pane"
--     auto_detect_pane = true, -- Auto-detect opencode pane in current window
--   },
--   keys = {
--     { "<leader>oc", "<cmd>OpencodeSend<cr>", desc = "Send prompt to opencode" },
--     { "<leader>oc", "<cmd>OpencodeSend<cr>", mode = "v", desc = "Send prompt to opencode" },
--     { "<leader>ot", "<cmd>OpencodeSwitchMode<cr>", desc = "Toggle opencode mode" },
--     { "<leader>op", "<cmd>OpencodePrompt<cr>", desc = "Open opencode persistent prompt" },
--   },
--   cmd = { "OpencodeSend", "OpencodeSwitchMode" },
-- }

return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    -- Recommended for ask() and select().
    -- Required for toggle().
    { "folke/snacks.nvim", opts = { input = {}, picker = {} } },
  },
  config = function()
    vim.g.opencode_opts = {
      default_target = "tmux",
    }

    -- Required for vim.g.opencode_opts.auto_reload.
    vim.o.autoread = true

    -- Recommended/example keymaps.
    vim.keymap.set({ "n", "x" }, "<leader>oa", function()
      require("opencode").ask("@this: ", { submit = true })
    end, { desc = "Ask about this" })
    vim.keymap.set({ "n", "x" }, "<leader>os", function()
      require("opencode").select()
    end, { desc = "Select prompt" })
    vim.keymap.set({ "n", "x" }, "<leader>o+", function()
      require("opencode").prompt("@this")
    end, { desc = "Add this" })
    vim.keymap.set("n", "<leader>ot", function()
      require("opencode").toggle()
    end, { desc = "Toggle embedded" })
    vim.keymap.set("n", "<leader>oc", function()
      require("opencode").command()
    end, { desc = "Select command" })
    vim.keymap.set("n", "<leader>on", function()
      require("opencode").command("session_new")
    end, { desc = "New session" })
    vim.keymap.set("n", "<leader>oi", function()
      require("opencode").command("session_interrupt")
    end, { desc = "Interrupt session" })
    vim.keymap.set("n", "<leader>oA", function()
      require("opencode").command("agent_cycle")
    end, { desc = "Cycle selected agent" })
    vim.keymap.set("n", "<leader>oy", function()
      require("opencode").command("messages_copy")
    end, { desc = "Copy last message" })
    vim.keymap.set("n", "<S-C-u>", function()
      require("opencode").command("messages_half_page_up")
    end, { desc = "Messages half page up" })
    vim.keymap.set("n", "<S-C-d>", function()
      require("opencode").command("messages_half_page_down")
    end, { desc = "Messages half page down" })
  end,
}
