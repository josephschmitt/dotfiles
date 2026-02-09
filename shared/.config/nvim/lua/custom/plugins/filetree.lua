-- Neo-tree: file tree sidebar (like VS Code's explorer panel).
-- Provides three views: filesystem, open buffers, and git status.
-- Auto-opens on wide screens, auto-closes after opening a file on narrow screens.
-- https://github.com/nvim-neo-tree/neo-tree.nvim

local AUTO_CLOSE_WIDTH = 150

local function should_auto_close()
  return vim.o.columns <= AUTO_CLOSE_WIDTH
end

return {
  {
    "nvim-neo-tree/neo-tree.nvim",
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
        width = 40, -- 40 columns wide
        mappings = {
          ["l"] = "open", -- Expand folder or open file
          ["h"] = "close_node", -- Collapse folder
          ["H"] = "prev_source", -- Switch to previous source tab
          ["L"] = "next_source", -- Switch to next source tab
          ["Q"] = function() vim.cmd("qa") end, -- Quit Neovim
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

      -- Auto-open/close neo-tree when the terminal is resized across the threshold
      vim.api.nvim_create_autocmd("VimResized", {
        group = vim.api.nvim_create_augroup("neotree-auto-resize", { clear = true }),
        callback = function()
          if should_auto_close() then
            pcall(require("neo-tree.command").execute, { action = "close" })
          else
            pcall(require("neo-tree.command").execute, { action = "show" })
          end
        end,
      })
    end,
  },
}
