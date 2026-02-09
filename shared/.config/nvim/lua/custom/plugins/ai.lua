-- claudecode.nvim: Claude Code integration via WebSocket.
-- Enables Claude (running in an external tmux pane) to read/edit Neovim buffers.
-- https://github.com/coder/claudecode.nvim
return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  lazy = false, -- Load at startup to ensure WebSocket server starts
  opts = {
    -- Use "none" provider - Claude runs in external tmux pane
    terminal_provider = "none",
    auto_start = true, -- Auto-start WebSocket server

    -- Configure diff behavior to open in new tabs
    diff_opts = {
      open_in_current_tab = false, -- Open diffs in new tab instead of split
    },

    -- Keymaps for diff review
    keymaps = {
      accept = "<Leader>aa", -- Accept Claude's changes
      deny = "<Leader>ad", -- Reject changes
      edit = "<Leader>ae", -- Edit before accepting
    },
  },

  keys = {
    {
      "<Leader>ac",
      function()
        vim.fn.system('tmux split-window -h -l 100 -c "#{pane_current_path}" "claude"')
      end,
      desc = "Launch Claude in tmux split",
    },
    {
      "<Leader>aC",
      function()
        vim.fn.system("tmux select-pane -t $(tmux list-panes -F '#{pane_id}:#{pane_current_command}' | grep claude | cut -d: -f1)")
      end,
      desc = "Focus Claude tmux pane",
    },
    {
      "<Leader>as",
      function()
        local file = vim.fn.expand("%:p")
        vim.cmd("ClaudeCodeAdd " .. file)
      end,
      desc = "Send current file to Claude",
    },
    {
      "<Leader>aS",
      "<cmd>ClaudeCodeSend<cr>",
      desc = "Send selection to Claude",
      mode = { "n", "v" },
    },
  },
}
