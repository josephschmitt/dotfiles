-- File tree sidebar (like VS Code's explorer panel).
-- Supports three providers controlled by config.filetree_provider:
--   "snacks"     — snacks.nvim explorer (picker in sidebar layout, default)
--   "nvim-tree"  — nvim-tree.lua (standalone, stable)
--   "neo-tree"   — neo-tree.nvim (three views: filesystem, buffers, git status)
-- Only the active provider's spec is enabled; the others are disabled by lazy.nvim.
-- To switch: change filetree_provider in config.lua and run :Lazy sync.

local config = require("custom.config")

local function should_auto_close()
  return vim.o.columns <= config.filetree_auto_close_width
end

return {
  -- ──────────────────────────────────────────────────────────────────────────
  -- snacks.nvim explorer
  -- Picker-based sidebar explorer built into snacks.nvim (already a dep).
  -- No extra plugin install needed; configured via opts.picker.sources.explorer.
  -- https://github.com/folke/snacks.nvim/blob/main/docs/explorer.md
  -- ──────────────────────────────────────────────────────────────────────────
  {
    "folke/snacks.nvim",
    enabled = config.filetree_provider == "snacks",
    opts = {
      explorer = {
        replace_netrw = true, -- snacks handles netrw; options.lua guard is a no-op
      },
      picker = {
        sources = {
          explorer = {
            -- Sidebar layout, no preview pane by default (toggle with <Tab>)
            layout = { preset = "sidebar", preview = false },
            -- Show hidden (dotfiles) by default; toggle with `.` in the list.
            -- `ignored = false` still hides git-ignored files.
            hidden = true,
            -- Dynamically set jump.close based on screen width at confirm time:
            -- closes after opening a file on narrow screens, stays open on wide ones.
            actions = {
              confirm_smart = function(picker, item)
                picker.opts.jump.close = vim.o.columns <= require("custom.config").filetree_auto_close_width
                picker:action("confirm", item)
              end,
            },
            win = {
              list = {
                keys = {
                  -- Esc closes the explorer from the list (mirrors nvim-tree/neo-tree)
                  ["<Esc>"] = "close",
                  -- Override confirm to dynamically decide whether to close based on width
                  ["l"] = "confirm_smart",
                  ["<CR>"] = "confirm_smart",
                  -- / is already toggle_focus by default: jumps to the search input
                },
              },
              input = {
                keys = {
                  -- Esc from the search input returns to the list (not close)
                  ["<Esc>"] = { "focus_list", mode = { "n", "i" } },
                },
              },
            },
          },
        },
      },
    },
    keys = {
      {
        "<Leader>ee",
        function() config.filetree.toggle() end,
        desc = "Toggle Explorer (current file)",
      },
      {
        "<Leader>eE",
        function() Snacks.picker.explorer({ cwd = vim.uv.cwd() }) end,
        desc = "Toggle Explorer (cwd)",
      },
      {
        "<Leader>er",
        function() config.filetree.reload() end,
        desc = "Refresh Explorer",
      },
      {
        "<Leader>o",
        function()
          if vim.bo.filetype == config.filetree.filetype then
            vim.cmd("wincmd p")
            -- Close the explorer after jumping away on narrow screens
            if vim.o.columns <= config.filetree_auto_close_width then
              pcall(config.filetree.close)
            end
          else
            pcall(config.filetree.focus)
          end
        end,
        desc = "Toggle explorer focus",
      },
    },
    -- Auto-close autocmds are registered in picker.lua's config function,
    -- which owns the snacks.nvim setup call.
  },

  -- ──────────────────────────────────────────────────────────────────────────
  -- nvim-tree.lua
  -- Simple, fast file explorer. No multi-source views, but very stable.
  -- https://github.com/nvim-tree/nvim-tree.lua
  -- ──────────────────────────────────────────────────────────────────────────
  {
    "nvim-tree/nvim-tree.lua",
    enabled = config.filetree_provider == "nvim-tree",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      {
        "<Leader>ee",
        function()
          config.filetree.toggle()
        end,
        desc = "Toggle Explorer (current file)",
      },
      {
        "<Leader>eE",
        function()
          require("nvim-tree.api").tree.toggle({ path = vim.uv.cwd() })
        end,
        desc = "Toggle Explorer (cwd)",
      },
      {
        "<Leader>er",
        function()
          config.filetree.reload()
        end,
        desc = "Refresh Explorer",
      },
      {
        "<Leader>o",
        function()
          if vim.bo.filetype == config.filetree.filetype then
            vim.cmd("wincmd p")
          else
            pcall(config.filetree.focus)
          end
        end,
        desc = "Toggle explorer focus",
      },
    },
    config = function()
      local api = require("nvim-tree.api")

      -- Custom keybindings for the tree window
      local function on_attach(bufnr)
        local opts = function(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        -- Load all default mappings first, then selectively override
        api.config.mappings.default_on_attach(bufnr)

        -- Navigation: l to open, h to collapse (vim-style)
        vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
        vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Collapse"))

        -- Toggle dotfiles visibility
        vim.keymap.set("n", ".", api.tree.toggle_hidden_filter, opts("Toggle dotfiles"))

        -- Close tree with Escape
        vim.keymap.set("n", "<Esc>", api.tree.close, opts("Close"))
      end

      require("nvim-tree").setup({
        on_attach = on_attach,
        view = {
          width = config.filetree_width,
          side = "left",
        },
        -- Keep the tree focused on the file you are editing
        update_focused_file = {
          enable = true,
        },
        -- File watcher: auto-refresh when files change on disk (enabled by default)
        filesystem_watchers = {
          enable = true,
        },
        filters = {
          dotfiles = false, -- Show dotfiles (like .config/)
          git_ignored = true, -- Hide git-ignored files
          custom = { "^\\.git$", "^\\.gitkeep$" }, -- Always hide these
        },
      })

      -- Auto-close when a file is opened on a narrow screen
      api.events.subscribe(api.events.Event.FileOpened, function()
        if should_auto_close() then
          api.tree.close()
        end
      end)

      -- Auto-close on focus lost when screen is narrow.
      -- WinLeave fires when leaving the tree window; vim.schedule defers the
      -- close until after the new window has focus so nvim-tree's internal
      -- "is_visible" state is stable when we call close().
      vim.api.nvim_create_autocmd("WinLeave", {
        group = vim.api.nvim_create_augroup("nvimtree-auto-close-focus", { clear = true }),
        callback = function()
          if should_auto_close() and vim.bo.filetype == "NvimTree" then
            vim.schedule(function()
              api.tree.close()
            end)
          end
        end,
      })

      -- Auto-open/close when the terminal is resized across the threshold
      vim.api.nvim_create_autocmd("VimResized", {
        group = vim.api.nvim_create_augroup("nvimtree-auto-resize", { clear = true }),
        callback = function()
          if should_auto_close() then
            pcall(api.tree.close)
          else
            pcall(api.tree.open)
          end
        end,
      })
    end,
  },

  -- ──────────────────────────────────────────────────────────────────────────
  -- neo-tree.nvim
  -- Multi-source explorer (filesystem, buffers, git status).
  -- https://github.com/nvim-neo-tree/neo-tree.nvim
  -- ──────────────────────────────────────────────────────────────────────────
  {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = config.filetree_provider == "neo-tree",
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim", -- Lua utility library (required by many plugins)
      "nvim-tree/nvim-web-devicons", -- File type icons
      "MunifTanjim/nui.nvim", -- UI component library for the tree rendering
    },
    keys = {
      { "<Leader>ee", "<Cmd>Neotree toggle<CR>", desc = "Toggle Explorer (current file)" },
      { "<Leader>eE", "<Cmd>Neotree toggle dir=<CR>", desc = "Toggle Explorer (cwd)" },
      { "<Leader>eb", "<Cmd>Neotree buffers<CR>", desc = "Buffer Explorer" },
      { "<Leader>eg", "<Cmd>Neotree git_status<CR>", desc = "Git Explorer" },
      {
        "<Leader>er",
        function()
          config.filetree.reload()
        end,
        desc = "Refresh Explorer",
      },
      {
        "<Leader>o",
        function()
          if vim.bo.filetype == config.filetree.filetype then
            vim.cmd("wincmd p")
          else
            pcall(config.filetree.focus)
          end
        end,
        desc = "Toggle explorer focus",
      },
    },
    opts = {
      source_selector = {
        winbar = true, -- Show source tabs at top of neo-tree window
        sources = {
          { source = "filesystem", display_name = " Files" },
          { source = "buffers", display_name = " Buffers" },
          { source = "git_status", display_name = " Git" },
        },
      },
      window = {
        position = "left", -- Open on left side
        width = config.filetree_width, -- Width in columns
        mappings = {
          ["l"] = "open", -- Expand folder or open file
          ["h"] = "close_node", -- Collapse folder
          ["H"] = "prev_source", -- Switch to previous source tab
          ["L"] = "next_source", -- Switch to next source tab
          ["<Esc>"] = "close_window", -- Close neo-tree with Escape
          ["."] = "toggle_hidden", -- Toggle dotfiles visibility
          ["I"] = function(state) -- Toggle gitignored files visibility
            state.filtered_items = state.filtered_items or {}
            state.filtered_items.hide_gitignored = not state.filtered_items.hide_gitignored
            require("neo-tree.log").info("Toggling gitignored files: " .. tostring(not state.filtered_items.hide_gitignored))
            require("neo-tree.sources.manager").refresh("filesystem")
          end,
        },
      },
      event_handlers = {
        -- Auto-close neo-tree after opening a file when screen is narrow
        {
          event = "file_opened",
          handler = function()
            if should_auto_close() then
              require("neo-tree.command").execute({ action = "close" })
            end
          end,
        },
        -- Auto-close neo-tree on focus lost when screen is narrow
        {
          event = "neo_tree_buffer_leave",
          handler = function()
            if should_auto_close() then
              require("neo-tree.command").execute({ action = "close" })
            end
          end,
        },
      },
      filesystem = {
        hijack_netrw_behavior = "disabled", -- We handle directory opening in options.lua
        follow_current_file = { enabled = true }, -- Tree highlights the file you're editing
        use_libuv_file_watcher = true, -- Auto-refresh when files change on disk
        filtered_items = {
          visible = false, -- Hide filtered items (don't just dim them)
          hide_dotfiles = false, -- Show dotfiles (like .config/)
          hide_gitignored = true, -- Hide git-ignored files
          hide_by_name = { ".git", ".gitkeep" }, -- Always hide these
        },
      },
    },
    config = function(_, opts)
      require("neo-tree").setup(opts)

      -- Auto-open/close the tree when the terminal is resized across the threshold
      vim.api.nvim_create_autocmd("VimResized", {
        group = vim.api.nvim_create_augroup("neotree-auto-resize", { clear = true }),
        callback = function()
          if should_auto_close() then
            pcall(config.filetree.close)
          else
            pcall(config.filetree.open)
          end
        end,
      })
    end,
  },
}
