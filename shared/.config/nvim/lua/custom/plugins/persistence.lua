-- persistence.nvim: auto-save and restore sessions per working directory.
-- Sessions are saved on exit and can be restored from the dashboard or via commands.
-- Integrates with Snacks dashboard's session section.

local AUTO_CLOSE_WIDTH = 150

-- Wipe any neo-tree buffers/windows (stale from session or live)
local function wipe_neotree()
  -- Close via neo-tree API first (if it's loaded)
  pcall(function()
    require("neo-tree.command").execute({ action = "close" })
  end)
  -- Force-wipe any leftover neo-tree buffers by name
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(buf)
    if name:match("neo%-tree ") then
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
  end
end

return {
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {
      -- Wipe neo-tree before saving so ghost buffers don't end up in the session
      pre_save = wipe_neotree,
    },
    config = function(_, opts)
      require("persistence").setup(opts)

      -- After a session is restored: clean up stale neo-tree state,
      -- then auto-open neo-tree if screen is wide enough
      local group = vim.api.nvim_create_augroup("persistence-neotree", { clear = true })
      vim.api.nvim_create_autocmd("SessionLoadPost", {
        group = group,
        callback = function()
          -- Wipe ghost neo-tree buffers from the restored session
          wipe_neotree()

          -- Auto-open neo-tree on wide screens after restore
          if vim.o.columns > AUTO_CLOSE_WIDTH then
            vim.defer_fn(function()
              pcall(require("neo-tree.command").execute, { action = "show" })
            end, 100)
          end
        end,
      })
    end,
  },
}
