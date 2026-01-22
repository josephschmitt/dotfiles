-- Custom plugin configurations
-- Plugins imported from AstroCommunity are configured here when customization is needed.
-- Plugins not available in AstroCommunity are added as custom specs.

---@type LazySpec
return {
  -- Which-key configuration - use helix preset and add group icons
  {
    "folke/which-key.nvim",
    opts = {
      preset = "helix",
      spec = {
        { "<leader>a", group = " AI Agent" },
        { "<leader>e", group = "󰙅 Explorer" },
        { "<leader>m", group = " Multicursor" },
        { "<leader>w", group = "󱂬 Window" },
        { "<leader><Tab>", group = "󰓩 Tabs" },
      },
    },
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
      local mc = require "multicursor-nvim"
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

  -- Override AstroCore mappings to customize Yazi keybindings
  {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      local maps = opts.mappings
      -- Disable default AstroCommunity yazi keybindings
      maps.n["<Leader>-"] = false
      maps.v["<Leader>-"] = false
      maps.n["<Leader>Yc"] = false
      maps.n["<Leader>Yt"] = false

      -- Add custom keybindings under <leader>e (explorer)
      local yazi_current = { function() require("yazi").yazi() end, desc = "Yazi (current file)" }
      maps.n["<Leader>ey"] = yazi_current
      maps.v["<Leader>ey"] = yazi_current
      maps.n["<Leader>eY"] = { function() require("yazi").yazi(nil, vim.fn.getcwd()) end, desc = "Yazi (cwd)" }
      maps.n["<Leader>et"] = { function() require("yazi").toggle() end, desc = "Resume Yazi" }
    end,
  },

  -- Mode highlighting with tokyonight colors
  {
    "mvllow/modes.nvim",
    enabled = false, -- Disabled: causes startup messages. Re-enable if you want mode highlighting
    opts = function()
      local colors = require("tokyonight.colors").setup { style = "night" }
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

  -- Tiny inline diagnostics customization (from AstroCommunity)
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    optional = true, -- Only apply if tiny-inline-diagnostic is loaded from AstroCommunity
    opts = {
      preset = "powerline",
      options = {
        show_source = {
          enabled = false,
          if_many = true,
        },
        use_icons_from_diagnostic = true,
        multilines = true,
      },
    },
  },

  -- CodeDiff viewer customization (from AstroCommunity)
  {
    "esmuellert/codediff.nvim",
    optional = true, -- Only apply if codediff is loaded from AstroCommunity
    opts = {
      highlights = {
        line_insert = "DiffAdd",
        line_delete = "DiffDelete",
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
      },
    },
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

  -- Mini AI - smart text objects based on indent, treesitter, or patterns
  {
    "echasnovski/mini.ai",
    version = "*",
    config = function() require("mini.ai").setup() end,
  },

  -- Mini Surround - surround text with brackets, quotes, etc.
  {
    "echasnovski/mini.surround",
    version = "*",
    config = function() require("mini.surround").setup() end,
  },

  -- ASCII.nvim - ASCII art generator for dashboard
  {
    "MaximilianLloyd/ascii.nvim",
  },

  -- Configure snacks dashboard to use ASCII art
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      -- Load ascii art and set as header
      local ok, ascii = pcall(require, "ascii")
      if ok then
        local art = ascii.art.text.neovim.ansi_shadow
        if art then
          if type(art) == "table" then art = table.concat(art, "\n") end
          opts.dashboard.preset.header = art
        end
      end
      return opts
    end,
  },
}
