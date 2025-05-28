local LazyVim = require("lazyvim.util")
return {
  "zbirenbaum/copilot.lua",
  enabled = not vim.g.vscode,
  opts = function()
    LazyVim.cmp.actions.ai_accept = function()
      if require("copilot.suggestion").is_visible() then
        LazyVim.create_undo()
        require("copilot.suggestion").accept()
        return true
      end
    end
  end,
}
