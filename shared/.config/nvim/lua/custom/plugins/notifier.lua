-- Snacks notifier: toast-style notification popups.
-- Replaces vim.notify with floating windows in the corner.
-- https://github.com/folke/snacks.nvim/blob/main/docs/notifier.md
return {
  {
    "folke/snacks.nvim",
    opts = {
      notifier = {
        enabled = true,
        timeout = 3000, -- 3 seconds default
      },
    },
    keys = {
      {
        "<Leader>tN",
        function()
          Snacks.notifier.hide()
        end,
        desc = "Dismiss all notifications",
      },
      {
        "<Leader>fn",
        function()
          Snacks.picker.notifications()
        end,
        desc = "Find Notifications",
      },
    },
  },
}
