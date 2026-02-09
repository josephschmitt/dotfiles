-- multicursor.nvim: multi-cursor editing.
-- Arrow keys add/navigate cursors. <Leader>m group for match-based operations.
-- When multiple cursors are active, a keymap layer activates:
--   <left>/<right> to cycle cursors, <leader>x to delete one, <esc> to clear all.
return {
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
        "<Leader>ma",
        function() require("multicursor-nvim").matchAllAddCursors() end,
        desc = "Add cursors for all word/selection matches",
        mode = { "n", "x" },
      },
      {
        "<Leader>mc",
        function() require("multicursor-nvim").addCursorOperator() end,
        desc = "Add cursors for motion",
        mode = "n",
      },
      {
        "<Leader>mo",
        function() require("multicursor-nvim").operator() end,
        desc = "Add cursors for match operator",
        mode = { "n", "x" },
      },
      {
        "<Leader>mA",
        function() require("multicursor-nvim").searchAllAddCursors() end,
        desc = "Add cursors to every search result",
        mode = { "n", "x" },
      },
      {
        "<Leader>mn",
        function() require("multicursor-nvim").searchAddCursor(1) end,
        desc = "Add cursor and jump to next search result",
        mode = "n",
      },
      {
        "<Leader>mN",
        function() require("multicursor-nvim").searchAddCursor(-1) end,
        desc = "Add cursor and jump to previous search result",
        mode = "n",
      },
      {
        "<Leader>ms",
        function() require("multicursor-nvim").searchSkipCursor(1) end,
        desc = "Jump to next search result without adding cursor",
        mode = "n",
      },
      {
        "<Leader>mS",
        function() require("multicursor-nvim").searchSkipCursor(-1) end,
        desc = "Jump to previous search result without adding cursor",
        mode = "n",
      },
      {
        "<Leader>mt",
        function() require("multicursor-nvim").transposeCursors(1) end,
        desc = "Rotate text between cursors forward",
        mode = "x",
      },
      {
        "<Leader>mT",
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
}
