-- Custom vim options that override kickstart defaults.
-- These run when lazy.nvim loads this file, before VimEnter.

local config = require("custom.config")

-- Relative line numbers for easy jump counting (kickstart only enables number)
vim.o.relativenumber = true

-- Disable line wrapping (toggleable with <Leader>tw)
vim.o.wrap = false

-- Hide command line when not in use (no blank gap below statusline)
vim.o.cmdheight = 0

-- Global statusline (one at the bottom instead of per-window)
-- Prevents statusline from appearing in the file tree and other splits
vim.o.laststatus = 3

-- RPC server: create a socket so external tools (terminal popups, git
-- commit editors, etc.) can open files in this running Neovim instance.
-- Socket path: ~/.local/state/nvim/nvim.<pid>.sock
local socket_path = vim.fn.stdpath("state") .. "/nvim." .. vim.fn.getpid() .. ".sock"
pcall(vim.fn.serverstart, socket_path)

-- Disable netrw (replaced by file tree + dashboard for directory browsing)
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1

-- SSH clipboard: remote boxes often have no clipboard binary (xclip/wl-copy)
-- and Neovim's built-in OSC-52 auto-detect only kicks in when 'clipboard' is
-- empty (kickstart's init.lua sets it to unnamedplus), so it's silently
-- skipped. Force the OSC-52 provider directly over SSH so yanks reach the
-- local terminal's clipboard regardless of tmux/clipboard-tool availability.
-- Local (non-SSH) sessions are untouched and keep using pbcopy/etc.
-- NOTE: sshd only sets SSH_TTY when a pty was allocated for the session —
-- on some boxes (e.g. this fleet's remote-sandbox machines) it comes back
-- empty even for normal interactive logins. SSH_CONNECTION is set whenever
-- there's a remote client at all, TTY or not, so check both for coverage
-- across whatever quirks a given server/client combo has.
--
-- NOTE: `herdr --remote` bridges to remote sandboxes over its own transport
-- instead of sshd, so neither SSH_TTY nor SSH_CONNECTION is set even though
-- the session is just as remote. Herdr always sets HERDR_SOCKET_PATH (and
-- other HERDR_* vars) in its pane environment, so check that too. Herdr
-- v0.4.6+ passes OSC 52 sequences from child apps through to the host
-- terminal, so forcing the provider here reaches the local clipboard the
-- same way it does over plain SSH.
--
-- NOTE: intentionally no `paste` provider. OSC-52 paste requires the
-- terminal to answer a query over the same TTY with the clipboard contents;
-- most terminals (and anything behind tmux) don't implement that response
-- leg, or block it by default for security. Wiring paste up to
-- osc52.paste() makes every p/P send that query and then hang forever on
-- "Waiting for OSC 52 response" since no reply ever arrives. Without a
-- custom paste, p/P just fall back to normal register behavior (instant,
-- no host-clipboard fetch) — copy-out still works, paste just doesn't
-- pull from the host clipboard.
if vim.env.SSH_TTY or vim.env.SSH_CONNECTION or vim.env.HERDR_SOCKET_PATH then
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
  }
end

-- Directory opener: when Neovim is launched with a directory argument,
-- set the cwd, show the Snacks dashboard, and reveal the file tree.
vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("custom-dir-opener", { clear = true }),
  callback = function(args)
    local bufname = vim.api.nvim_buf_get_name(args.buf)
    if bufname == "" or vim.fn.isdirectory(bufname) ~= 1 then return end

    -- Set working directory
    vim.cmd.cd(bufname)

    -- Delete the directory buffer (no longer needed)
    vim.api.nvim_buf_delete(args.buf, { force = true })

    -- Open dashboard in the current window (not as a float), then the file tree.
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
        pcall(config.filetree.focus)
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
-- Skips floating windows (pickers, notifications, etc.) and file tree (has its own header)
vim.api.nvim_create_autocmd("WinEnter", {
  group = vim.api.nvim_create_augroup("custom-winbar", { clear = true }),
  callback = function()
    if vim.api.nvim_win_get_config(0).relative ~= "" then return end

    -- Skip file tree windows (they manage their own header)
    if vim.bo.filetype == config.filetree.filetype then return end

    local wins = vim.api.nvim_tabpage_list_wins(0)
    local normal_wins = vim.tbl_filter(function(win)
      local buf = vim.api.nvim_win_get_buf(win)
      return vim.bo[buf].buftype == "" and vim.api.nvim_win_get_config(win).relative == ""
    end, wins)

    vim.wo.winbar = #normal_wins > 1 and "%f %m" or ""
  end,
})

return {}
