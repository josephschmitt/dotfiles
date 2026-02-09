-- UI toggles under <Leader>t, inspired by AstroNvim's toggle system.
-- Each toggle shows a notification with the new state.

local function notify(feature, state)
  vim.notify(feature .. (state and " enabled" or " disabled"), vim.log.levels.INFO)
end

-- Track global toggle states
local autoformat_disabled_globally = false
local autoformat_disabled_buffers = {}

return {
  -- Override conform to respect our autoformat toggles
  {
    "stevearc/conform.nvim",
    opts = {
      format_on_save = function(bufnr)
        if autoformat_disabled_globally or autoformat_disabled_buffers[bufnr] then
          return nil
        end
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        end
        return { timeout_ms = 500, lsp_format = "fallback" }
      end,
    },
  },

  -- All toggle keybindings (registered via lazy.nvim keys on which-key)
  {
    "folke/which-key.nvim",
    keys = {
      -- Auto-format (buffer)
      {
        "<Leader>tf",
        function()
          local bufnr = vim.api.nvim_get_current_buf()
          autoformat_disabled_buffers[bufnr] = not autoformat_disabled_buffers[bufnr]
          notify("Auto-format (buffer)", not autoformat_disabled_buffers[bufnr])
        end,
        desc = "Toggle auto-format (buffer)",
      },

      -- Auto-format (global)
      {
        "<Leader>tF",
        function()
          autoformat_disabled_globally = not autoformat_disabled_globally
          notify("Auto-format (global)", not autoformat_disabled_globally)
        end,
        desc = "Toggle auto-format (global)",
      },

      -- Word wrap
      {
        "<Leader>tw",
        function()
          vim.wo.wrap = not vim.wo.wrap
          notify("Word wrap", vim.wo.wrap)
        end,
        desc = "Toggle word wrap",
      },

      -- Line numbers
      {
        "<Leader>tn",
        function()
          vim.wo.number = not vim.wo.number
          notify("Line numbers", vim.wo.number)
        end,
        desc = "Toggle line numbers",
      },

      -- Relative line numbers
      {
        "<Leader>tr",
        function()
          vim.wo.relativenumber = not vim.wo.relativenumber
          notify("Relative numbers", vim.wo.relativenumber)
        end,
        desc = "Toggle relative numbers",
      },

      -- Spell check
      {
        "<Leader>ts",
        function()
          vim.wo.spell = not vim.wo.spell
          notify("Spell check", vim.wo.spell)
        end,
        desc = "Toggle spell check",
      },

      -- Diagnostics
      {
        "<Leader>td",
        function()
          local enabled = vim.diagnostic.is_enabled()
          vim.diagnostic.enable(not enabled)
          notify("Diagnostics", not enabled)
        end,
        desc = "Toggle diagnostics",
      },

      -- Inlay hints (buffer)
      {
        "<Leader>th",
        function()
          local bufnr = vim.api.nvim_get_current_buf()
          local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
          vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
          notify("Inlay hints (buffer)", not enabled)
        end,
        desc = "Toggle inlay hints (buffer)",
      },

      -- Inlay hints (global)
      {
        "<Leader>tH",
        function()
          local enabled = vim.lsp.inlay_hint.is_enabled()
          vim.lsp.inlay_hint.enable(not enabled)
          notify("Inlay hints (global)", not enabled)
        end,
        desc = "Toggle inlay hints (global)",
      },

      -- Autocompletion (buffer)
      {
        "<Leader>tc",
        function()
          local bufnr = vim.api.nvim_get_current_buf()
          local disabled = vim.b[bufnr].blink_cmp_disabled
          vim.b[bufnr].blink_cmp_disabled = not disabled
          notify("Autocompletion (buffer)", disabled)
        end,
        desc = "Toggle autocompletion (buffer)",
      },

      -- Autocompletion (global)
      {
        "<Leader>tC",
        function()
          local disabled = vim.g.blink_cmp_disabled
          vim.g.blink_cmp_disabled = not disabled
          notify("Autocompletion (global)", disabled)
        end,
        desc = "Toggle autocompletion (global)",
      },

      -- Conceal
      {
        "<Leader>tS",
        function()
          vim.wo.conceallevel = vim.wo.conceallevel == 0 and 2 or 0
          notify("Conceal", vim.wo.conceallevel > 0)
        end,
        desc = "Toggle conceal",
      },

      -- Syntax highlighting (buffer)
      {
        "<Leader>ty",
        function()
          if vim.b.ts_highlight then
            vim.treesitter.stop()
            notify("Treesitter highlight", false)
          else
            vim.treesitter.start()
            notify("Treesitter highlight", true)
          end
        end,
        desc = "Toggle syntax highlighting (buffer)",
      },
    },
  },
}
