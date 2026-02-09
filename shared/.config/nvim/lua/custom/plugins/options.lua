-- Custom vim options that override kickstart defaults.
-- These run when lazy.nvim loads this file, before VimEnter.

-- Relative line numbers for easy jump counting (kickstart only enables number)
vim.o.relativenumber = true

-- Disable line wrapping (toggleable with <Leader>tw)
vim.o.wrap = false

-- RPC server: create a socket so external tools (terminal popups, git
-- commit editors, etc.) can open files in this running Neovim instance.
-- Socket path: ~/.local/state/nvim/nvim.<pid>.sock
local socket_path = vim.fn.stdpath("state") .. "/nvim." .. vim.fn.getpid() .. ".sock"
pcall(vim.fn.serverstart, socket_path)

-- Auto-cd when opening a directory (e.g. `nvim .` or `nvim some-dir/`)
vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("custom-autocd", { clear = true }),
  callback = function(args)
    local bufname = vim.api.nvim_buf_get_name(args.buf)
    if bufname ~= "" and vim.fn.isdirectory(bufname) == 1 then
      vim.cmd.cd(bufname)
    end
  end,
})

-- Markdown: show all syntax characters (disable concealing)
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("custom-markdown", { clear = true }),
  pattern = { "markdown" },
  callback = function()
    vim.wo.conceallevel = 0
  end,
})

-- Smart winbar: show filename only when multiple splits exist.
-- Skips floating windows (pickers, notifications, etc.)
vim.api.nvim_create_autocmd("WinEnter", {
  group = vim.api.nvim_create_augroup("custom-winbar", { clear = true }),
  callback = function()
    if vim.api.nvim_win_get_config(0).relative ~= "" then return end

    local wins = vim.api.nvim_tabpage_list_wins(0)
    local normal_wins = vim.tbl_filter(function(win)
      local buf = vim.api.nvim_win_get_buf(win)
      return vim.bo[buf].buftype == "" and vim.api.nvim_win_get_config(win).relative == ""
    end, wins)

    vim.wo.winbar = #normal_wins > 1 and "%f %m" or ""
  end,
})

return {}
