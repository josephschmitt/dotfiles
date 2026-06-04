-- persistence.nvim: auto-save and restore sessions per working directory.
-- Sessions are saved on exit and can be restored from the dashboard or via commands.
-- Integrates with Snacks dashboard's session section.

local config = require("custom.config")

-- Wipe any file tree buffers/windows (stale from session or live)
local function wipe_filetree()
  -- Close via the adapter API first (if the plugin is loaded)
  pcall(config.filetree.close)
  -- Force-wipe any leftover file tree buffers
  config.filetree.wipe_buffers()
end

return {
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {
      -- Wipe file tree before saving so ghost buffers don't end up in the session
      pre_save = wipe_filetree,
    },
    config = function(_, opts)
      require("persistence").setup(opts)

      -- After a session is restored: clean up stale file tree state,
      -- then auto-open the file tree if screen is wide enough
      local group = vim.api.nvim_create_augroup("persistence-filetree", { clear = true })
      vim.api.nvim_create_autocmd("SessionLoadPost", {
        group = group,
        callback = function()
          -- Wipe ghost file tree buffers from the restored session
          wipe_filetree()

          -- Auto-open file tree on wide screens after restore
          if vim.o.columns > config.filetree_auto_close_width then
            vim.defer_fn(function()
              pcall(config.filetree.open)
            end, 100)
          end
        end,
      })
    end,
  },
}
