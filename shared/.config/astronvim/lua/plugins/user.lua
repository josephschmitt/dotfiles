-- Custom LazyVim plugins migrated to AstroNvim

---@type LazySpec
return {
  -- Bufferline with ordinal numbers and buffer navigation
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        numbers = "ordinal",
      },
    },
    config = function(_, opts)
      require("bufferline").setup(opts)
      -- Maps Ctrl-1-9 to go to the Nth visible buffer
      for i = 1, 9 do
        vim.keymap.set({ "n", "i", "v" }, ("<C-%d>"):format(i), ("<Cmd>BufferLineGoToBuffer %d<CR>"):format(i), {
          desc = ("Go to buffer %d"):format(i),
        })
      end
      -- Map Ctrl-0 to go to the last visible buffer
      vim.keymap.set({ "n", "i", "v" }, "<C-0>", function()
        local count = #vim.fn.getbufinfo({ buflisted = 1 })
        vim.cmd(("BufferLineGoToBuffer %d"):format(count))
      end, { desc = "Go to last buffer" })
    end,
  },

  -- Multi-cursor support
  {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    keys = {
      { "<up>", function() require("multicursor-nvim").lineAddCursor(-1) end, mode = { "n", "x" } },
      { "<down>", function() require("multicursor-nvim").lineAddCursor(1) end, mode = { "n", "x" } },
      {
        "<M-Down>",
        function() require("multicursor-nvim").matchAddCursor(1) end,
        desc = "Add cursor for word/selection",
        mode = { "n", "x" },
      },
      {
        "<M-Up>",
        function() require("multicursor-nvim").matchAddCursor(-1) end,
        desc = "Add cursor for word/selection backwards",
        mode = { "n", "x" },
      },
      {
        "<S-Down>",
        function() require("multicursor-nvim").lineSkipCursor(1) end,
        desc = "Skip cursor down",
        mode = { "n", "x" },
      },
      {
        "<S-Up>",
        function() require("multicursor-nvim").lineSkipCursor(-1) end,
        desc = "Skip cursor up",
        mode = { "n", "x" },
      },
      {
        "<leader>ma",
        function() require("multicursor-nvim").matchAllAddCursors() end,
        desc = "Add cursors for all word/selection matches",
        mode = { "n", "x" },
      },
      {
        "<leader>mc",
        function() require("multicursor-nvim").addCursorOperator() end,
        desc = "Add cursors for motion",
        mode = "n",
      },
      {
        "<leader>mo",
        function() require("multicursor-nvim").operator() end,
        desc = "Add cursors for match operator",
        mode = { "n", "x" },
      },
      {
        "<leader>mA",
        function() require("multicursor-nvim").searchAllAddCursors() end,
        desc = "Add cursors to every search result",
        mode = { "n", "x" },
      },
      {
        "<leader>mn",
        function() require("multicursor-nvim").searchAddCursor(1) end,
        desc = "Add cursor and jump to next search result",
        mode = "n",
      },
      {
        "<leader>mN",
        function() require("multicursor-nvim").searchAddCursor(-1) end,
        desc = "Add cursor and jump to previous search result",
        mode = "n",
      },
      {
        "<leader>ms",
        function() require("multicursor-nvim").searchSkipCursor(1) end,
        desc = "Jump to next search result without adding cursor",
        mode = "n",
      },
      {
        "<leader>mS",
        function() require("multicursor-nvim").searchSkipCursor(-1) end,
        desc = "Jump to previous search result without adding cursor",
        mode = "n",
      },
      {
        "<leader>mt",
        function() require("multicursor-nvim").transposeCursors(1) end,
        desc = "Rotate text between cursors forward",
        mode = "x",
      },
      {
        "<leader>mT",
        function() require("multicursor-nvim").transposeCursors(-1) end,
        desc = "Rotate text between cursors backward",
        mode = "x",
      },
      {
        "I",
        function() require("multicursor-nvim").insertVisual() end,
        desc = "Insert at beginning of visual selections",
        mode = "x",
      },
      {
        "A",
        function() require("multicursor-nvim").appendVisual() end,
        desc = "Append at end of visual selections",
        mode = "x",
      },
    },
    config = function()
      local mc = require("multicursor-nvim")
      mc.setup()
      mc.addKeymapLayer(function(layerSet)
        layerSet({ "n", "x" }, "<left>", mc.prevCursor)
        layerSet({ "n", "x" }, "<right>", mc.nextCursor)
        layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)
        layerSet("n", "<esc>", function()
          if not mc.cursorsEnabled() then
            mc.enableCursors()
          else
            mc.clearCursors()
          end
        end)
      end)
      local hl = vim.api.nvim_set_hl
      hl(0, "MultiCursorCursor", { link = "Cursor" })
      hl(0, "MultiCursorVisual", { link = "Visual" })
      hl(0, "MultiCursorSign", { link = "SignColumn" })
      hl(0, "MultiCursorMatchPreview", { link = "Search" })
      hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
      hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
      hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
    end,
  },

  -- Yazi file manager
  {
    "mikavilpas/yazi.nvim",
    dependencies = { "folke/snacks.nvim" },
    keys = {
      { "<leader>fy", mode = { "n", "v" }, "<cmd>Yazi<cr>", desc = "Yazi (current file)" },
      { "<leader>y", mode = { "n", "v" }, "<cmd>Yazi<cr>", desc = "Yazi (current file)" },
      { "<leader>fY", "<cmd>Yazi cwd<cr>", desc = "Yazi (cwd)" },
      { "<leader>Y", "<cmd>Yazi cwd<cr>", desc = "Yazi (cwd)" },
    },
    opts = {
      floating_window_scaling_factor = 0.8,
    },
  },

  -- Mode highlighting with tokyonight colors
  {
    "mvllow/modes.nvim",
    enabled = false, -- Disabled: causes startup messages. Re-enable if you want mode highlighting
    opts = function()
      local colors = require("tokyonight.colors").setup({ style = "night" })
      return {
        colors = {
          copy = colors.orange,
          delete = colors.red,
          insert = colors.green,
          visual = "#e178fa",
        },
        line_opacity = 0.15,
        set_cursor = true,
        set_cursorline = true,
        set_number = true,
        set_signcolumn = true,
      }
    end,
  },

  -- Tiny inline diagnostics
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    priority = 1000,
    config = function()
      require("tiny-inline-diagnostic").setup({
        preset = "powerline",
        options = {
          show_source = {
            enabled = false,
            if_many = true,
          },
          use_icons_from_diagnostic = true,
          multilines = true,
        },
      })
    end,
  },

  -- CodeDiff viewer
  {
    "esmuellert/codediff.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    cmd = "CodeDiff",
    config = function()
      require("codediff").setup({
        highlights = {
          line_insert = "DiffAdd",
          line_delete = "DiffDelete",
          char_insert = nil,
          char_delete = nil,
          char_brightness = nil,
          conflict_sign = nil,
          conflict_sign_resolved = nil,
          conflict_sign_accepted = nil,
          conflict_sign_rejected = nil,
        },
        diff = {
          disable_inlay_hints = true,
          max_computation_time_ms = 5000,
          hide_merge_artifacts = false,
        },
        explorer = {
          position = "left",
          width = 40,
          height = 15,
          indent_markers = true,
          icons = {
            folder_closed = "",
            folder_open = "",
          },
          view_mode = "list",
          file_filter = {
            ignore = {},
          },
        },
        keymaps = {
          view = {
            quit = "q",
            toggle_explorer = "<leader>b",
            next_hunk = "]c",
            prev_hunk = "[c",
            next_file = "]f",
            prev_file = "[f",
            diff_get = "do",
            diff_put = "dp",
          },
          explorer = {
            select = "<CR>",
            hover = "K",
            refresh = "R",
            toggle_view_mode = "i",
          },
          conflict = {
            accept_incoming = "<leader>ct",
            accept_current = "<leader>co",
            accept_both = "<leader>cb",
            discard = "<leader>cx",
            next_conflict = "]x",
            prev_conflict = "[x",
            diffget_incoming = "2do",
            diffget_current = "3do",
          },
        },
      })
    end,
  },

  -- Sort JSON
  {
    "2nthony/sortjson.nvim",
    cmd = {
      "SortJSONByAlphaNum",
      "SortJSONByAlphaNumReverse",
      "SortJSONByKeyLength",
      "SortJSONByKeyLengthReverse",
    },
    opts = {
      jq = "jq",
      log_level = "WARN",
    },
  },

  -- Textobj fold
  {
    "somini/vim-textobj-fold",
    dependencies = { "kana/vim-textobj-user" },
    event = "VeryLazy",
    keys = {
      { "z", group = "Fold Textobj" },
      { "zi", "<Plug>(textobj-fold-i)", mode = { "x", "o" }, desc = "Inside Fold (Strict)" },
      { "za", "<Plug>(textobj-fold-a)", mode = { "x", "o" }, desc = "Around Fold" },
    },
  },
}
