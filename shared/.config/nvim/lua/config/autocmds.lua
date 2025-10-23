-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Automatically set the current working directory when focusing a directory
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 1 then
      local arg0 = vim.fn.argv(0) --[[@as string]]
      if vim.fn.isdirectory(arg0) == 1 then
        vim.cmd.cd(arg0)
        vim.cmd("silent! 0")
      end
    end
  end,
})

-- Disable conceal level for markdown files
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.md", "*.markdown" }, -- or "*" if you want it globally
  callback = function()
    vim.opt.conceallevel = 0
  end,
})

-- Show dashboard when all buffers are deleted
vim.api.nvim_create_autocmd("BufDelete", {
  callback = function()
    vim.schedule(function()
      local bufs = vim.fn.getbufinfo({ buflisted = 1 })
      local real_bufs = vim.tbl_filter(function(buf)
        return buf.name ~= ""
      end, bufs)
      if #real_bufs == 0 then
        require("snacks").dashboard()
      end
    end)
  end,
})

-- Shell syntax conversion keymap (only for shell filetypes)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "sh", "bash", "zsh", "fish" },
  callback = function()
    local utils = require("config.utils")
    vim.keymap.set({ "v", "V" }, "<leader>cs", utils.convert_shell_syntax, {
      desc = "Convert shell syntax (POSIX ↔ Fish)",
      buffer = true
    })
  end,
})
