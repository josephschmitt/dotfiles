-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Force a specific node version for global hnvm
vim.env.HNVM_NODE = "22.14.0"
vim.env.HVNM_QUIET = true

-- LazyVim root dir detection
vim.g.root_spec = { { ".git", "package.json" }, "cwd" }

-- Cursor shapes for different modes
vim.opt.guicursor = {
  "n-v-c:block",
  "v:hor10",
  "i-ci:ver25",
  "r-cr:hor20",
  "o:hor50",
}

-- Split border characters
vim.opt.fillchars:append({ vert = "│", horiz = "─", horizup = "┴", horizdown = "┬" })

-- Make split borders visible with bright blue color
local function set_winseparator_hl()
  vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#7aa2f7", bg = "NONE", bold = true })
end

-- Apply after colorscheme changes
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = set_winseparator_hl,
})

-- Apply after LazyVim loads (with delay to override theme defaults)
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(set_winseparator_hl, 100)
  end,
})

-- Disable tabline (force after LazyVim loads and on every buffer change)
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  callback = function()
    vim.opt.showtabline = 0
  end,
})

-- Show filename in winbar only when multiple splits exist
vim.api.nvim_create_autocmd("WinEnter", {
  callback = function()
    -- Skip floating windows (used by pickers, notifications, etc.)
    if vim.api.nvim_win_get_config(0).relative ~= "" then
      return
    end

    local wins = vim.api.nvim_tabpage_list_wins(0)
    local normal_wins = vim.tbl_filter(function(win)
      local buf = vim.api.nvim_win_get_buf(win)
      local is_normal_buf = vim.bo[buf].buftype == ""
      local is_normal_win = vim.api.nvim_win_get_config(win).relative == ""
      return is_normal_buf and is_normal_win
    end, wins)

    vim.wo.winbar = #normal_wins > 1 and "%f %m" or ""
  end,
})
