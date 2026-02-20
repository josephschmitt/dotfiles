-- Snacks picker: replaces Telescope as the fuzzy finder for everything.
-- Snacks.picker is part of folke/snacks.nvim (which we already use for the dashboard).
-- It provides file finding, grep, LSP symbols, buffers, and more.
-- https://github.com/folke/snacks.nvim/blob/main/docs/picker.md
return {
  -- Disable Telescope (replaced by Snacks picker)
  { "nvim-telescope/telescope.nvim", enabled = false },
  { "nvim-telescope/telescope-fzf-native.nvim", enabled = false },
  { "nvim-telescope/telescope-ui-select.nvim", enabled = false },

  -- Configure Snacks picker (extends the snacks.nvim spec from dashboard.lua)
  {
    "folke/snacks.nvim",
    event = "VimEnter", -- Load at startup (needed for dashboard)
    keys = {
      -- Smart picker: finds files if in a clean dir, recent buffers if you have some open
      { "<Leader><Space>", function() require("snacks").picker.smart() end, desc = "Smart picker" },

      -- Find group (<Leader>f*) — files, buffers, grep, and metadata
      { "<Leader>ff", function() require("snacks").picker.files() end, desc = "Find Files" },
      { "<Leader>fb", function() require("snacks").picker.buffers() end, desc = "Find Buffers" },
      { "<Leader>fr", function() require("snacks").picker.recent() end, desc = "Find Recent Files" },
      -- "<Leader>fn" is used for Find Notifications (notifier.lua)
      { "<Leader>fP", function() require("snacks").picker.pickers() end, desc = "Find Pickers" },
      { "<Leader>fg", function() require("snacks").picker.grep() end, desc = "Find by Grep" },
      { "<Leader>fw", function() require("snacks").picker.grep_word() end, mode = { "n", "v" }, desc = "Find current Word" },
      { "<Leader>fh", function() require("snacks").picker.help() end, desc = "Find Help" },
      { "<Leader>fk", function() require("snacks").picker.keymaps() end, desc = "Find Keymaps" },
      { "<Leader>fd", function() require("snacks").picker.diagnostics() end, desc = "Find Diagnostics" },
      { "<Leader>fc", function() require("snacks").picker.commands() end, desc = "Find Commands" },
      { "<Leader>f.", function() require("snacks").picker.resume() end, desc = "Find Resume (repeat last)" },
      { "<Leader>f/", function() require("snacks").picker.grep_buffers() end, desc = "Find in Open Files" },

      -- Top-level shortcut (also in which-key spec, but needs to be here for lazy-loading)
      { "<Leader>/", function() require("snacks").picker.lines() end, desc = "Search buffer" },
    },

    opts = {
      picker = {
        -- Use the picker's built-in UI select to replace vim.ui.select
        -- (equivalent to telescope-ui-select.nvim)
        ui_select = true,
        -- Remap toggle keys from Alt to Shift (normal mode only).
        -- Alt conflicts with tmux navigation (Alt+hjkl).
        win = {
          input = {
            keys = {
              ["H"] = { "toggle_hidden", mode = { "n" } },
              ["I"] = { "toggle_ignored", mode = { "n" } },
              ["F"] = { "toggle_follow", mode = { "n" } },
              ["R"] = { "toggle_regex", mode = { "n" } },
              ["M"] = { "toggle_maximize", mode = { "n" } },
              ["P"] = { "toggle_preview", mode = { "n" } },
              ["D"] = { "inspect", mode = { "n" } },
              ["W"] = { "cycle_win", mode = { "n" } },
            },
          },
        },
        -- Show hidden files (dotfiles) by default in file/grep pickers.
        -- Essential for dotfiles repos and .config/ directories.
        sources = {
          files = { hidden = true },
          grep = { hidden = true },
          smart = { hidden = true },
        },
      },
    },

    config = function(_, opts)
      -- Custom "JoeVim" header in ANSI Shadow style
      if opts.dashboard and opts.dashboard.preset then
        opts.dashboard.preset.header = table.concat({
          [[                                                ]],
          [[      ██╗ ██████╗ ███████╗██╗   ██╗██╗███╗   ███╗ ]],
          [[      ██║██╔═══██╗██╔════╝██║   ██║██║████╗ ████║ ]],
          [[      ██║██║   ██║█████╗  ██║   ██║██║██╔████╔██║ ]],
          [[ ██   ██║██║   ██║██╔══╝  ╚██╗ ██╔╝██║██║╚██╔╝██║ ]],
          [[ ╚█████╔╝╚██████╔╝███████╗ ╚████╔╝ ██║██║ ╚═╝ ██║ ]],
          [[  ╚════╝  ╚═════╝ ╚══════╝  ╚═══╝  ╚═╝╚═╝     ╚═╝ ]],
          [[                                                ]],
        }, "\n")
      end

      require("snacks").setup(opts)

      -- LSP picker keybindings (set on LspAttach so they're buffer-local)
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("snacks-lsp-attach", { clear = true }),
        callback = function(event)
          local buf = event.buf
          local picker = require("snacks").picker

          vim.keymap.set("n", "grr", function() picker.lsp_references() end, { buffer = buf, desc = "Goto References" })
          vim.keymap.set("n", "gri", function() picker.lsp_implementations() end, { buffer = buf, desc = "Goto Implementation" })
          vim.keymap.set("n", "grd", function() picker.lsp_definitions() end, { buffer = buf, desc = "Goto Definition" })
          vim.keymap.set("n", "grs", function() picker.lsp_symbols() end, { buffer = buf, desc = "Document Symbols" })
          vim.keymap.set("n", "grS", function() picker.lsp_workspace_symbols() end, { buffer = buf, desc = "Workspace Symbols" })
          vim.keymap.set("n", "grt", function() picker.lsp_type_definitions() end, { buffer = buf, desc = "Goto Type Definition" })
        end,
      })
    end,
  },
}
