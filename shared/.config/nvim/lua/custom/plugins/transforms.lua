-- Transform group (gx): case manipulation, boolean toggle, increment/decrement.
-- Provides single-action versions of Vim's case operators (gu/gU/g~) that
-- act on the word under the cursor, plus boolean toggling and number
-- increment/decrement with memorable keybindings.

local boolean_pairs = {
  ["true"] = "false",
  ["false"] = "true",
  ["True"] = "False",
  ["False"] = "True",
  ["TRUE"] = "FALSE",
  ["FALSE"] = "TRUE",
  ["yes"] = "no",
  ["no"] = "yes",
  ["Yes"] = "No",
  ["No"] = "Yes",
  ["on"] = "off",
  ["off"] = "on",
  ["On"] = "Off",
  ["Off"] = "On",
  ["ON"] = "OFF",
  ["OFF"] = "ON",
  ["1"] = "0",
  ["0"] = "1",
}

local function toggle_boolean()
  local word = vim.fn.expand("<cword>")
  local replacement = boolean_pairs[word]
  if replacement then
    vim.cmd("normal! ciw" .. replacement)
    vim.cmd("stopinsert")
  else
    vim.notify("No boolean toggle for: " .. word, vim.log.levels.WARN)
  end
end

return {
  {
    "folke/which-key.nvim",
    keys = {
      { "gxu", "guiw", desc = "Lowercase word", remap = true },
      { "gxU", "gUiw", desc = "Uppercase word", remap = true },
      { "gx~", "g~iw", desc = "Toggle case word", remap = true },
      { "gxt", toggle_boolean, desc = "Toggle boolean" },
      { "gx+", "<C-a>", desc = "Increment number" },
      { "gx-", "<C-x>", desc = "Decrement number" },
      {
        "gxo",
        function()
          vim.ui.open(vim.fn.expand("<cfile>"))
        end,
        desc = "Open URL/filepath",
      },
    },
  },
}
