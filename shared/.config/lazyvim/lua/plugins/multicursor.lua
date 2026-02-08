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
    {
      "<S-Down>",
      function()
        require("multicursor-nvim").lineSkipCursor(1)
      end,
      desc = "Add cursor for word/selection",
      mode = { "n", "x" },
    },
    {
      "<S-Up>",
      function()
        require("multicursor-nvim").lineSkipCursor(-1)
      end,
      desc = "Add cursor for word/selection backwards",
      mode = { "n", "x" },
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

    -- Add a cursor to every search result in the buffer.
    {
      "<leader>mA",
      function()
        require("multicursor-nvim").searchAllAddCursors()
      end,
      desc = "Add cursors to every search result",
      mode = { "n", "x" },
    },

    -- Add a cursor and jump to the next/previous search result.
    {
      "<leader>mn",
      function()
        require("multicursor-nvim").searchAddCursor(1)
      end,
      desc = "Add cursor and jump to next search result",
      mode = "n",
    },
    {
      "<leader>mN",
      function()
        require("multicursor-nvim").searchAddCursor(-1)
      end,
      desc = "Add cursor and jump to previous search result",
      mode = "n",
    },

    -- Jump to the next/previous search result without adding a cursor.
    {
      "<leader>ms",
      function()
        require("multicursor-nvim").searchSkipCursor(1)
      end,
      desc = "Jump to next search result without adding cursor",
      mode = "n",
    },
    {
      "<leader>mS",
      function()
        require("multicursor-nvim").searchSkipCursor(-1)
      end,
      desc = "Jump to previous search result without adding cursor",
      mode = "n",
    },

    -- Rotate the text contained in each visual selection between cursors.
    {
      "<leader>mt",
      function()
        require("multicursor-nvim").transposeCursors(1)
      end,
      desc = "Rotate text between cursors forward",
      mode = "x",
    },
    {
      "<leader>mT",
      function()
        require("multicursor-nvim").transposeCursors(-1)
      end,
      desc = "Rotate text between cursors backward",
      mode = "x",
    },

    -- Append/insert for each line of visual selections.
    -- Similar to block selection insertion.
    {
      "I",
      function()
        require("multicursor-nvim").insertVisual()
      end,
      desc = "Insert at beginning of visual selections",
      mode = "x",
    },
    {
      "A",
      function()
        require("multicursor-nvim").appendVisual()
      end,
      desc = "Append at end of visual selections",
      mode = "x",
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
