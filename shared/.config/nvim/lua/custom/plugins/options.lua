-- Custom vim options that override kickstart defaults.
-- These run when lazy.nvim loads this file, before VimEnter.

-- Relative line numbers for easy jump counting (kickstart only enables number)
vim.o.relativenumber = true

-- Disable line wrapping (toggleable with <Leader>tw)
vim.o.wrap = false

-- Hide command line when not in use (no blank gap below statusline)
vim.o.cmdheight = 0

-- Global statusline (one at the bottom instead of per-window)
-- Prevents statusline from appearing in neo-tree and other splits
vim.o.laststatus = 3

-- RPC server: create a socket so external tools (terminal popups, git
-- commit editors, etc.) can open files in this running Neovim instance.
-- Socket path: ~/.local/state/nvim/nvim.<pid>.sock
local socket_path = vim.fn.stdpath("state") .. "/nvim." .. vim.fn.getpid() .. ".sock"
pcall(vim.fn.serverstart, socket_path)

-- Disable netrw (replaced by neo-tree + dashboard for directory browsing)
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1

-- Directory opener: when Neovim is launched with a directory argument,
-- set the cwd, show the Snacks dashboard, and reveal neo-tree.
vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("custom-dir-opener", { clear = true }),
  callback = function(args)
    local bufname = vim.api.nvim_buf_get_name(args.buf)
    if bufname == "" or vim.fn.isdirectory(bufname) ~= 1 then return end

    -- Set working directory
    vim.cmd.cd(bufname)

    -- Delete the directory buffer (no longer needed)
    vim.api.nvim_buf_delete(args.buf, { force = true })

    -- Open dashboard in the current window (not as a float), then neo-tree.
    -- Passing buf/win to dashboard.open() makes it render into the window
    -- like the normal VimEnter startup path does.
    vim.schedule(function()
      local ok_snacks = pcall(require, "snacks")
      if ok_snacks then
        local buf = vim.api.nvim_get_current_buf()
        local win = vim.api.nvim_get_current_win()
        require("snacks").dashboard.open({ buf = buf, win = win })
      end

      vim.schedule(function()
        local ok_neotree = pcall(require, "neo-tree.command")
        if ok_neotree then
          require("neo-tree.command").execute({ action = "focus" })
        end
      end)
    end)
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

-- Text files: enable word wrap by default
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("custom-text-wrap", { clear = true }),
  pattern = { "markdown", "text", "rst", "tex" },
  callback = function()
    vim.wo.wrap = true
    vim.wo.linebreak = true
  end,
})

-- Smart winbar: show filename only when multiple splits exist.
-- Skips floating windows (pickers, notifications, etc.) and neo-tree (has its own winbar)
vim.api.nvim_create_autocmd("WinEnter", {
  group = vim.api.nvim_create_augroup("custom-winbar", { clear = true }),
  callback = function()
    if vim.api.nvim_win_get_config(0).relative ~= "" then return end

    -- Skip neo-tree windows (they manage their own winbar for source tabs)
    if vim.bo.filetype == "neo-tree" then return end

    local wins = vim.api.nvim_tabpage_list_wins(0)
    local normal_wins = vim.tbl_filter(function(win)
      local buf = vim.api.nvim_win_get_buf(win)
      return vim.bo[buf].buftype == "" and vim.api.nvim_win_get_config(win).relative == ""
    end, wins)

    vim.wo.winbar = #normal_wins > 1 and "%f %m" or ""
  end,
})

return {}
