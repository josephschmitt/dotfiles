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

    -- Keymaps for diff review (aligned with your patterns)
    keymaps = {
      accept = "<Leader>aa", -- Accept Claude's changes
      deny = "<Leader>ad", -- Reject changes
      edit = "<Leader>ae", -- Edit before accepting
    },
  },

  -- Keybindings that control tmux directly
  keys = {
    {
      "<Leader>ac",
      function()
        -- Launch Claude in tmux split (same as Prefix A)
        vim.fn.system 'tmux split-window -h -l 100 -c "#{pane_current_path}" "claude"'
      end,
      desc = "Launch Claude in tmux split",
    },
    {
      "<Leader>aC",
      function()
        -- Focus the Claude tmux pane (find pane running 'claude' and select it)
        vim.fn.system "tmux select-pane -t $(tmux list-panes -F '#{pane_id}:#{pane_current_command}' | grep claude | cut -d: -f1)"
      end,
      desc = "Focus Claude tmux pane",
    },
    {
      "<Leader>as",
      function()
        local file = vim.fn.expand "%:p"
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
