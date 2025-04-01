return {
  {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    keys = {
      -- Add or skip cursor above/below the main cursor.
      {
        "<C-k>",
        function()
          require("multicursor-nvim").lineAddCursor(-1)
        end,
        mode = { "n", "x" },
        desc = "Add cursor above",
      },
      {
        "<C-j>",
        function()
          require("multicursor-nvim").lineAddCursor(1)
        end,
        mode = { "n", "x" },
        desc = "Add cursor below",
      },
      {
        "<leader><Up>",
        function()
          require("multicursor-nvim").lineSkipCursor(-1)
        end,
        mode = { "n", "x" },
        desc = "Skip cursor above",
      },
      {
        "<leader><Down>",
        function()
          require("multicursor-nvim").lineSkipCursor(1)
        end,
        mode = { "n", "x" },
        desc = "Skip cursor below",
      },

      -- Add or skip adding a new cursor by matching word/selection
      {
        "<leader>n",
        function()
          require("multicursor-nvim").matchAddCursor(1)
        end,
        mode = { "n", "x" },
        desc = "Add cursor to next match",
      },
      {
        "<leader>s",
        function()
          require("multicursor-nvim").matchSkipCursor(1)
        end,
        mode = { "n", "x" },
        desc = "Skip cursor to next match",
      },
      {
        "<leader>N",
        function()
          require("multicursor-nvim").matchAddCursor(-1)
        end,
        mode = { "n", "x" },
        desc = "Add cursor to previous match",
      },
      {
        "<leader>S",
        function()
          require("multicursor-nvim").matchSkipCursor(-1)
        end,
        mode = { "n", "x" },
        desc = "Skip cursor to previous match",
      },

      -- Add and remove cursors with control + left click.
      {
        "<C-LeftMouse>",
        function()
          require("multicursor-nvim").handleMouse()
        end,
        mode = "n",
        desc = "Handle mouse click for multicursor",
      },
      {
        "<C-LeftDrag>",
        function()
          require("multicursor-nvim").handleMouseDrag()
        end,
        mode = "n",
        desc = "Handle mouse drag for multicursor",
      },
      {
        "<C-LeftRelease>",
        function()
          require("multicursor-nvim").handleMouseRelease()
        end,
        mode = "n",
        desc = "Handle mouse release for multicursor",
      },

      -- Disable and enable cursors.
      {
        "<C-q>",
        function()
          require("multicursor-nvim").toggleCursor()
        end,
        mode = { "n", "x" },
        desc = "Toggle multicursor",
      },
    },
    config = function()
      local mc = require("multicursor-nvim")
      mc.setup()

      -- Mappings defined in a keymap layer only apply when there are
      -- multiple cursors. This lets you have overlapping mappings.
      mc.addKeymapLayer(function(layerSet)
        -- Select a different cursor as the main one.
        layerSet({ "n", "x" }, "<Left>", mc.prevCursor)
        layerSet({ "n", "x" }, "<Right>", mc.nextCursor)

        -- Delete the main cursor.
        layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)

        -- Enable and clear cursors using escape.
        layerSet("n", "<Esc>", function()
          if not mc.cursorsEnabled() then
            mc.enableCursors()
          else
            mc.clearCursors()
          end
        end)
      end)

      -- Customize how cursors look.
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
}
