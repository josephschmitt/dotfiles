-- Core keybindings ported from AstroNvim/LazyVim.
-- These are non-leader convenience mappings that improve daily editing flow.
-- Uses VimEnter to ensure they load after plugins (e.g. Comment.nvim for gcc/gc).
vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("custom-keymaps", { clear = true }),
  callback = function()
    local map = vim.keymap.set

    -- Undo/redo: U for redo (mirrors u for undo)
    map({ "n", "v" }, "U", "<C-r>", { desc = "Redo" })

    -- Exit insert mode shortcuts
    map("i", "jk", "<Esc>", { desc = "Exit insert mode" })
    map("i", "kj", "<Esc>", { desc = "Exit insert mode" })
    map("i", "jj", "<Esc>", { desc = "Exit insert mode" })

    -- macOS Cmd+V paste in all modes
    map("", "<D-v>", "+p<CR>", { noremap = true, silent = true })
    map("!", "<D-v>", "<C-R>+", { noremap = true, silent = true })
    map("t", "<D-v>", "<C-R>+", { noremap = true, silent = true })
    map("v", "<D-v>", "<C-R>+", { noremap = true, silent = true })

    -- Comment line with Ctrl+C
    map("n", "<C-c>", "gcc", { remap = true, desc = "Comment line" })
    map("v", "<C-c>", "gc", { remap = true, desc = "Comment selection" })

    -- Indent/unindent in normal mode (stay in place)
    map("n", "<", "<<", { desc = "Unindent line" })
    map("n", ">", ">>", { desc = "Indent line" })

    -- Go to beginning/end of line (Helix-style)
    map({ "n", "v" }, "gh", "0", { desc = "Go to beginning of line" })
    map({ "n", "v" }, "gl", "$", { desc = "Go to end of line" })

    -- Select all
    map("n", "gV", "ggVG", { desc = "Select all" })
  end,
})

return {}
