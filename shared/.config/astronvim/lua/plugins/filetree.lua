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
    },
  },
}
