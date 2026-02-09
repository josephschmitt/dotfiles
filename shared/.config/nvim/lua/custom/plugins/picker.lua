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

      -- Find group (<Leader>f*) — locating files, buffers, and specific items
      { "<Leader>ff", function() require("snacks").picker.files() end, desc = "Find Files" },
      { "<Leader>fb", function() require("snacks").picker.buffers() end, desc = "Find Buffers" },
      { "<Leader>fr", function() require("snacks").picker.recent() end, desc = "Find Recent Files" },
      { "<Leader>fn", function() require("snacks").picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Neovim files" },
      { "<Leader>fp", function() require("snacks").picker.pickers() end, desc = "Find Pickers" },

      -- Search group (<Leader>s*) — searching content, help, and metadata
      { "<Leader>sg", function() require("snacks").picker.grep() end, desc = "Search by Grep" },
      { "<Leader>sw", function() require("snacks").picker.grep_word() end, mode = { "n", "v" }, desc = "Search current Word" },
      { "<Leader>sh", function() require("snacks").picker.help() end, desc = "Search Help" },
      { "<Leader>sk", function() require("snacks").picker.keymaps() end, desc = "Search Keymaps" },
      { "<Leader>sd", function() require("snacks").picker.diagnostics() end, desc = "Search Diagnostics" },
      { "<Leader>sc", function() require("snacks").picker.commands() end, desc = "Search Commands" },
      { "<Leader>sr", function() require("snacks").picker.resume() end, desc = "Search Resume" },
      { "<Leader>s/", function() require("snacks").picker.grep_buffers() end, desc = "Search in Open Files" },

      -- Standalone shortcuts
      { "<Leader>/", function() require("snacks").picker.lines() end, desc = "Fuzzy search in current buffer" },
    },

    opts = {
      picker = {
        -- Use the picker's built-in UI select to replace vim.ui.select
        -- (equivalent to telescope-ui-select.nvim)
        ui_select = true,
      },
    },

    config = function(_, opts)
      -- Load ascii art for dashboard header (from dashboard.lua's opts)
      if opts.dashboard and opts.dashboard.preset then
        local ok, ascii = pcall(require, "ascii")
        if ok then
          local art = ascii.art.text.neovim.ansi_shadow
          if art then
            if type(art) == "table" then art = table.concat(art, "\n") end
            opts.dashboard.preset.header = art
          end
        end
      end

      require("snacks").setup(opts)

      -- LSP picker keybindings (set on LspAttach so they're buffer-local)
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("snacks-lsp-attach", { clear = true }),
        callback = function(event)
          local buf = event.buf
          local picker = require("snacks").picker

          -- Find references for the word under your cursor
          vim.keymap.set("n", "grr", function() picker.lsp_references() end, { buffer = buf, desc = "Goto References" })

          -- Jump to the implementation
          vim.keymap.set("n", "gri", function() picker.lsp_implementations() end, { buffer = buf, desc = "Goto Implementation" })

          -- Jump to the definition (press <C-t> to go back)
          vim.keymap.set("n", "grd", function() picker.lsp_definitions() end, { buffer = buf, desc = "Goto Definition" })

          -- Fuzzy find all symbols in current document
          vim.keymap.set("n", "gO", function() picker.lsp_symbols() end, { buffer = buf, desc = "Document Symbols" })

          -- Fuzzy find all symbols in workspace
          vim.keymap.set("n", "gW", function() picker.lsp_workspace_symbols() end, { buffer = buf, desc = "Workspace Symbols" })

          -- Jump to the type definition
          vim.keymap.set("n", "grt", function() picker.lsp_type_definitions() end, { buffer = buf, desc = "Goto Type Definition" })
        end,
      })
    end,
  },
}
