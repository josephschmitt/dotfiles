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
        { "gs", group = "󰅪 Surround" },
        { "gr", group = " LSP" },
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

  -- Override gitsigns to change gh prefix to <leader>gh (freeing gh for goto)
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      on_attach = function(bufnr)
        local gs = require "gitsigns"

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "]g", function()
          if vim.wo.diff then return "]c" end
          vim.schedule(function() gs.next_hunk() end)
          return "<Ignore>"
        end, { expr = true, desc = "Next Git hunk" })
        map("n", "[g", function()
          if vim.wo.diff then return "[c" end
          vim.schedule(function() gs.prev_hunk() end)
          return "<Ignore>"
        end, { expr = true, desc = "Previous Git hunk" })

        -- Actions under <leader>g instead of gh
        map("n", "<leader>gs", gs.stage_hunk, { desc = "Stage hunk" })
        map("n", "<leader>gr", gs.reset_hunk, { desc = "Reset hunk" })
        map("v", "<leader>gs", function() gs.stage_hunk { vim.fn.line ".", vim.fn.line "v" } end, { desc = "Stage hunk" })
        map("v", "<leader>gr", function() gs.reset_hunk { vim.fn.line ".", vim.fn.line "v" } end, { desc = "Reset hunk" })
        map("n", "<leader>gS", gs.stage_buffer, { desc = "Stage buffer" })
        map("n", "<leader>gu", gs.undo_stage_hunk, { desc = "Undo stage hunk" })
        map("n", "<leader>gR", gs.reset_buffer, { desc = "Reset buffer" })
        map("n", "<leader>gp", gs.preview_hunk, { desc = "Preview hunk" })
        map("n", "<leader>gb", function() gs.blame_line { full = true } end, { desc = "Blame line" })
        map("n", "<leader>ghd", gs.diffthis, { desc = "Diff this hunk" })
        map("n", "<leader>ghD", function() gs.diffthis "~" end, { desc = "Diff this hunk ~" })

        -- Text object
        map({ "o", "x" }, "ig", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select git hunk" })
      end,
    },
  },

  -- Override mini.move: Shift+hjkl visual only (Alt+hjkl used by tmux, normal mode conflicts with S-h/S-l buffer nav, J join, K hover)
  {
    "echasnovski/mini.move",
    optional = true,
    opts = {
      mappings = {
        -- Visual mode: Shift+hjkl to move selections
        left = "<S-h>",
        right = "<S-l>",
        down = "<S-j>",
        up = "<S-k>",
        -- Normal mode: disabled
        line_left = "",
        line_right = "",
        line_down = "",
        line_up = "",
      },
    },
  },

  -- Override mini.bracketed: disable buffer target (]b/[b already used for buffer nav)
  {
    "echasnovski/mini.bracketed",
    optional = true,
    opts = {
      buffer = { suffix = "" },
    },
  },

  -- Override mini.diff to disable gh mappings (freeing gh for goto)
  {
    "echasnovski/mini.diff",
    optional = true,
    opts = {
      mappings = {
        -- Disable all default mappings (gh prefix)
        apply = "",
        reset = "",
        textobject = "",
        goto_first = "",
        goto_prev = "",
        goto_next = "",
        goto_last = "",
      },
    },
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
  -- Using `gs` prefix to avoid conflict with flash.nvim's `s` mapping
  {
    "echasnovski/mini.surround",
    version = "*",
    opts = {
      mappings = {
        add = "gsa",
        delete = "gsd",
        find = "gsf",
        find_left = "gsF",
        highlight = "gsh",
        replace = "gsr",
        update_n_lines = "gsn",
      },
    },
  },

  -- Mini Pick - fuzzy picker
  {
    "echasnovski/mini.pick",
    version = "*",
    config = function() require("mini.pick").setup() end,
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

  -- Help tags completion for :help command
  {
    "PhilippFeO/cmp-help-tags",
    ft = "help", -- Load when opening help files
  },

  -- Customize cmp-cmdline to include help tag completion
  {
    "hrsh7th/cmp-cmdline",
    optional = true,
    opts = function()
      local cmp = require "cmp"
      return {
        {
          type = "/",
          mapping = cmp.mapping.preset.cmdline(),
          sources = {
            { name = "buffer" },
          },
        },
        {
          type = ":",
          mapping = cmp.mapping.preset.cmdline(),
          sources = cmp.config.sources({
            { name = "path" },
            { name = "cmp_help_tags" }, -- Help tags completion
          }, {
            {
              name = "cmdline",
              option = {
                ignore_cmds = { "Man", "!" },
              },
            },
          }),
        },
      }
    end,
  },

  -- Diffview - full diff view with layout toggle (from AstroCommunity)
  {
    "sindrets/diffview.nvim",
    optional = true, -- Only apply if diffview.nvim is loaded from AstroCommunity
    keys = {
      { "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
      { "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview File History" },
    },
    opts = {
      view = {
        default = {
          layout = "diff2_vertical", -- Top/bottom layout by default
          winbar_info = false,
        },
      },
      diff_binaries = false,
      enhanced_diff_hl = true,
      hooks = {
        diff_buf_read = function() vim.opt_local.wrap = true end,
      },
      keymaps = {
        view = {
          { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
        },
        file_panel = {
          { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
        },
      },
    },
  },

  -- pj.nvim - project navigation using pj binary
  {
    dir = "~/development/pj.nvim",
    dependencies = {
      "folke/snacks.nvim",
      "nvim-telescope/telescope.nvim",
      "ibhagwan/fzf-lua",
      "nvim-mini/mini.pick",
    },
    cmd = { "Pj", "PjCd" },
    keys = {
      { "<leader>fp", "<cmd>Pj<cr>", desc = "Find Projects (pj)" },
    },
    opts = {
      pj = { cmd = "auto" },
      picker = { type = "snacks" },
    },
  },
}
