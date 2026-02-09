-- Override stock kickstart mini.nvim config to add mini.move, mini.bracketed,
-- and change mini.surround to use gs prefix (matching AstroNvim).
return {
  {
    "nvim-mini/mini.nvim",
    config = function()
      -- mini.ai: smart text objects (around/inside)
      -- Examples: va) (visual around parens), ci' (change inside quotes)
      require("mini.ai").setup({ n_lines = 500 })

      -- mini.surround: add/delete/replace surroundings
      -- Using gs prefix to keep s free for future use (e.g. flash.nvim)
      -- Examples: gsaiw) (surround add inner word with parens),
      --           gsd' (surround delete quotes), gsr)' (replace parens with quotes)
      require("mini.surround").setup({
        mappings = {
          add = "gsa",
          delete = "gsd",
          find = "gsf",
          find_left = "gsF",
          highlight = "gsh",
          replace = "gsr",
          update_n_lines = "gsn",
        },
      })

      -- mini.statusline: simple status bar
      local statusline = require("mini.statusline")
      statusline.setup({ use_icons = vim.g.have_nerd_font })
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function() return "%2l:%-2v" end

      -- mini.move: move lines/selections with Shift+hjkl
      -- Visual mode only — normal mode disabled to avoid conflicts:
      --   S-h/S-l = buffer cycling, J = join lines, K = hover docs
      require("mini.move").setup({
        mappings = {
          left = "<S-h>",
          right = "<S-l>",
          down = "<S-j>",
          up = "<S-k>",
          line_left = "",
          line_right = "",
          line_down = "",
          line_up = "",
        },
      })

      -- mini.bracketed: ]x/[x navigation for buffers, diagnostics, quickfix, etc.
      -- Buffer target disabled (]b/[b already used by bufferline for buffer cycling)
      require("mini.bracketed").setup({
        buffer = { suffix = "" },
      })

      -- mini.indentscope: animated vertical line showing the current scope
      -- draw.predicate filters out non-file buffers (dashboard, neo-tree, etc.)
      require("mini.indentscope").setup({
        symbol = "│",
        options = { try_as_border = true },
        draw = {
          predicate = function(scope)
            if scope.body.is_incomplete then return false end
            if vim.bo.buftype ~= "" then return false end
            return true
          end,
        },
      })
    end,
  },
}
