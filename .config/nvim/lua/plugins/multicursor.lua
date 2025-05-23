return {
  "jake-stewart/multicursor.nvim",
  branch = "1.0",
  keys = {
    -- Add or skip cursor above/below the main cursor.
    {
      "<up>",
      function()
        require("multicursor-nvim").lineAddCursor(-1)
      end,
      mode = { "n", "x" },
    },
    {
      "<down>",
      function()
        require("multicursor-nvim").lineAddCursor(1)
      end,
      mode = { "n", "x" },
    },

    -- Add or skip adding a new cursor by matching word/selection
    {
      "<M-Down>",
      function()
        require("multicursor-nvim").matchAddCursor(1)
      end,
      desc = "Add cursor for word/selection",
      mode = { "n", "x" },
    },
    {
      "<M-Up>",
      function()
        require("multicursor-nvim").matchAddCursor(-1)
      end,
      desc = "Add cursor for word/selection backwards",
      mode = { "n", "x" },
    },

    -- Match new cursors within visual selections by regex.
    {
      "<leader>mr",
      function()
        require("multicursor-nvim").matchCursors()
      end,
      desc = "Match new cursors in selection by regex",
      mode = "x",
    },

    -- Add a cursor for all matches of cursor word/selection in the document.
    {
      "<leader>ma",
      function()
        require("multicursor-nvim").matchAllAddCursors()
      end,
      desc = "Add cursors for all word/selection matches",
      mode = { "n", "x" },
    },

    -- Add cursor for motion
    {
      "<leader>mc",
      function()
        require("multicursor-nvim").addCursorOperator()
      end,
      desc = "Add cursors for motion",
      mode = "n",
    },

    -- Add cursors for match operator
    {
      "<leader>mo",
      function()
        require("multicursor-nvim").operator()
      end,
      desc = "Add cursors for match operator",
      mode = { "n", "x" },
    },
  },
  config = function()
    local mc = require("multicursor-nvim")
    mc.setup()

    -- Mappings defined in a keymap layer only apply when there are
    -- multiple cursors. This lets you have overlapping mappings.
    mc.addKeymapLayer(function(layerSet)
      -- Select a different cursor as the main one.
      layerSet({ "n", "x" }, "<left>", mc.prevCursor)
      layerSet({ "n", "x" }, "<right>", mc.nextCursor)

      -- Delete the main cursor.
      layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)

      -- Enable and clear cursors using escape.
      layerSet("n", "<esc>", function()
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
}
