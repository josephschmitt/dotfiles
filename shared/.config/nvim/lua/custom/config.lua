-- Shared configuration constants used across multiple plugin files
local M = {
  -- Which file explorer to use: "snacks" | "nvim-tree" | "neo-tree"
  filetree_provider = "snacks",

  -- Sidebar width (used in filetree.lua, mini.lua for statusline offset, bufferline for offset)
  filetree_width = 40,

  -- Screen width threshold for auto-closing the file tree
  filetree_auto_close_width = 150,
}

-- Adapter: provides a uniform API regardless of which explorer is active.
-- All other files call config.filetree.{filetype,open,close,toggle,focus,reload,wipe_buffers}
-- so swapping the explorer only requires changing filetree_provider above and adding a spec
-- in filetree.lua — nothing else needs to change.

-- Shared helper: delete all bufs matching predicate(buf) → bool
local function wipe_bufs_matching(predicate)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if predicate(buf) then
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
  end
end

local adapters = {
  ["snacks"] = {
    -- The explorer is a snacks picker in sidebar layout. The list window has
    -- filetype "snacks_picker_list" — that's what bufferline/mini see.
    filetype = "snacks_picker_list",
    open = function()
      local p = Snacks.picker.get({ source = "explorer" })[1]
      if p then p:show() else Snacks.picker.explorer() end
    end,
    close = function()
      local p = Snacks.picker.get({ source = "explorer" })[1]
      if p then p:close() end
    end,
    toggle = function()
      local p = Snacks.picker.get({ source = "explorer" })[1]
      if p then p:close() else Snacks.picker.explorer() end
    end,
    focus = function()
      local p = Snacks.picker.get({ source = "explorer" })[1]
      if p then p:focus("list") else Snacks.picker.explorer() end
    end,
    reload = function()
      local p = Snacks.picker.get({ source = "explorer" })[1]
      if p then p:refresh() end
    end,
    wipe_buffers = function()
      wipe_bufs_matching(function(buf)
        return vim.bo[buf].filetype == "snacks_picker_list"
      end)
    end,
  },

  ["neo-tree"] = {
    filetype = "neo-tree",
    open = function()
      require("neo-tree.command").execute({ action = "show" })
    end,
    close = function()
      require("neo-tree.command").execute({ action = "close" })
    end,
    toggle = function()
      require("neo-tree.command").execute({ action = "toggle" })
    end,
    focus = function()
      require("neo-tree.command").execute({ action = "focus" })
    end,
    reload = function()
      require("neo-tree.sources.manager").refresh("filesystem")
    end,
    wipe_buffers = function()
      wipe_bufs_matching(function(buf)
        return vim.api.nvim_buf_get_name(buf):match("neo%-tree ") ~= nil
      end)
    end,
  },

  ["nvim-tree"] = {
    filetype = "NvimTree",
    open = function()
      require("nvim-tree.api").tree.open()
    end,
    close = function()
      require("nvim-tree.api").tree.close()
    end,
    toggle = function()
      require("nvim-tree.api").tree.toggle()
    end,
    focus = function()
      require("nvim-tree.api").tree.focus()
    end,
    reload = function()
      require("nvim-tree.api").tree.reload()
    end,
    wipe_buffers = function()
      wipe_bufs_matching(function(buf)
        return vim.bo[buf].filetype == "NvimTree"
      end)
    end,
  },
}

M.filetree = adapters[M.filetree_provider]

return M
