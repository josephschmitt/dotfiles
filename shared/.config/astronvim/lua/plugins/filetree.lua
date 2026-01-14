-- Configure neo-tree file explorer

---@type LazySpec
return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    window = {
      position = "left",
      width = 40,
    },
    filesystem = {
      follow_current_file = true,
      use_libuv_file_watcher = true,
      filtered_items = {
        visible = false,                       -- Hide filtered items (don't just dim them)
        hide_dotfiles = false,                 -- Show dotfiles (including .config/)
        hide_gitignored = true,                -- Hide git-ignored files
        hide_hidden = true,                    -- Windows-specific: show hidden files
        hide_ignored = true,                   -- Respect .ignore files
        ignore_files = { ".ignore" },          -- Only use .ignore (not .neotreeignore)
        hide_by_name = { ".git", ".gitkeep" }, -- Always hide .git and .gitkeep
      },
    },
  },
}
