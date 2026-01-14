-- Configure neo-tree file explorer

---@type LazySpec
return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    window = {
      position = "left",
      width = 30,
    },
    filesystem = {
      follow_current_file = true,
      use_libuv_file_watcher = true,
    },
  },
  init = function()
    -- Open neo-tree on VimEnter if no file is being edited
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        if vim.fn.argc() == 0 then
          require("neo-tree.command").execute({ action = "show" })
        end
      end,
    })
  end,
}
