-- Git plugins: gitsigns (hunk operations), mini.diff (inline overlay), diffview (full diff view).
-- All git keybindings live under <Leader>g with ]g/[g for hunk navigation.
return {
  -- Gitsigns: override stock kickstart config to add keybindings
  -- Adds git gutter signs and hunk-level stage/reset/preview/blame operations.
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      on_attach = function(bufnr)
        local gs = require("gitsigns")

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation: ]g / [g to jump between hunks
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

        -- Stage / reset
        map("n", "<Leader>gs", gs.stage_hunk, { desc = "Stage hunk" })
        map("v", "<Leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Stage hunk" })
        map("n", "<Leader>gr", gs.reset_hunk, { desc = "Reset hunk" })
        map("v", "<Leader>gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Reset hunk" })
        map("n", "<Leader>gS", gs.stage_buffer, { desc = "Stage buffer" })
        map("n", "<Leader>gR", gs.reset_buffer, { desc = "Reset buffer" })
        map("n", "<Leader>gu", gs.undo_stage_hunk, { desc = "Undo stage hunk" })

        -- View
        map("n", "<Leader>gp", gs.preview_hunk, { desc = "Preview hunk" })
        map("n", "<Leader>gb", function() gs.blame_line({ full = true }) end, { desc = "Blame line" })
        map("n", "<Leader>ghd", gs.diffthis, { desc = "Diff this" })
        map("n", "<Leader>ghD", function() gs.diffthis("~") end, { desc = "Diff against HEAD~" })

        -- Text object: "ig" selects the current hunk (e.g. vig, dig, cig)
        map({ "o", "x" }, "ig", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select git hunk" })
      end,
    },
  },

  -- mini.diff: inline diff overlay showing changes directly in the buffer.
  -- <Leader>gd toggles the unstaged diff overlay.
  -- <Leader>gD toggles a staged diff (compares working copy against HEAD).
  {
    "echasnovski/mini.diff",
    version = "*",
    event = "BufReadPost",
    opts = {
      mappings = {
        -- Disable all default mappings (gh prefix) — we use <Leader>g instead
        apply = "",
        reset = "",
        textobject = "",
        goto_first = "",
        goto_prev = "",
        goto_next = "",
        goto_last = "",
      },
    },
    keys = {
      {
        "<Leader>gd",
        function() require("mini.diff").toggle_overlay() end,
        desc = "View Git diff (unstaged)",
      },
      {
        "<Leader>gD",
        function()
          local MiniDiff = require("mini.diff")
          if vim.b.minidiff_showing_head then
            -- Toggle off: reset back to normal unstaged diff
            vim.b.minidiff_showing_head = false
            MiniDiff.disable()
            MiniDiff.enable()
          else
            -- Toggle on: show diff against HEAD (staged changes)
            vim.b.minidiff_showing_head = true
            local file = vim.api.nvim_buf_get_name(0)
            local relative_path = vim.fn.fnamemodify(file, ":.")
            local head_content = vim.fn.system("git show HEAD:" .. vim.fn.shellescape(relative_path))

            if vim.v.shell_error == 0 then
              MiniDiff.set_ref_text(0, head_content)
              local buf_data = MiniDiff.get_buf_data()
              if buf_data and not buf_data.overlay then
                vim.defer_fn(function() MiniDiff.toggle_overlay() end, 50)
              end
            else
              vim.notify("Could not get HEAD version of file", vim.log.levels.WARN)
            end
          end
        end,
        desc = "View Git diff (staged)",
      },
    },
  },

  -- Lazygit: floating terminal via Snacks (no extra plugin needed).
  -- Snacks auto-applies your Neovim colorscheme to lazygit.
  {
    "folke/snacks.nvim",
    keys = {
      { "<Leader>gg", function() require("snacks").lazygit() end, desc = "Lazygit" },
      { "<Leader>gl", function() require("snacks").lazygit.log() end, desc = "Lazygit Log" },
    },
  },

  -- diffview.nvim: full-screen side-by-side diff viewer.
  -- Opens a tab with all changed files, diff view, and file history.
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<Leader>gv", "<Cmd>DiffviewOpen<CR>", desc = "Diffview Open", icon = "" },
      { "<Leader>gH", "<Cmd>DiffviewFileHistory %<CR>", desc = "Diffview File History", icon = "" },
    },
    opts = {
      view = {
        default = {
          layout = "diff2_vertical",
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
          { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close Diffview" } },
        },
        file_panel = {
          { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close Diffview" } },
        },
      },
    },
  },
}
