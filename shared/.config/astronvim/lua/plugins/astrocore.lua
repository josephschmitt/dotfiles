-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics = { virtual_text = true, virtual_lines = false }, -- diagnostic settings on startup
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- disable notifications on startup
      show_intro = true, -- disable intro splash, use dashboard instead
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- passed to `vim.filetype.add`
    filetypes = {
      -- see `:h vim.filetype.add` for usage
      extension = {
        foo = "fooscript",
      },
      filename = {
        [".foorc"] = "fooscript",
      },
      pattern = {
        [".*/etc/foo/.*"] = "fooscript",
      },
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "yes", -- sets vim.opt.signcolumn to yes
        wrap = false, -- sets vim.opt.wrap
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map

        -- Undo/redo
        U = { "<C-r>", desc = "Redo" },

        -- Neo-tree source keymaps
        ["<Leader>be"] = { "<Cmd>Neotree buffers<CR>", desc = "Buffer Explorer" },
        ["<Leader>ge"] = { "<Cmd>Neotree git_status<CR>", desc = "Git Explorer" },

        -- Goto
        gh = { "0", desc = "Go to beginning of line" },
        gl = { "$", desc = "Go to end of line" },

        -- Window
        gw = { "<C-w>", desc = "Window mode" },
        ["<A-w>"] = { "<C-w>w", desc = "Switch window" },

        -- Indent
        ["<"] = { "<<", desc = "Unindent line" },
        [">"] = { ">>", desc = "Indent line" },

        -- Select all
        ["<C-a>"] = { "ggVG", desc = "Select all" },
        gV = { "ggVG", desc = "Select all" },

        -- Comment line
        ["<C-c>"] = { "gcc", remap = true, desc = "Comment line" },

        -- navigate buffer tabs
        ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

        -- Shift-hjkl for buffer navigation (LazyVim style)
        ["<S-h>"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },
        ["<S-l>"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },

        -- mappings seen under group name "Buffer"
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },

        -- setting a mapping to false will disable it
        -- ["<C-S>"] = false,
      },
      v = {
        -- Goto
        gh = { "0", desc = "Go to beginning of line" },
        gl = { "$", desc = "Go to end of line" },
        gw = { "<C-w>", desc = "Window mode" },

        -- Comment
        ["<C-c>"] = { "gc", remap = true, desc = "Comment line" },

        -- Helix-like
        ["<S-v>"] = { "j", desc = "Select down" },
      },
      i = {
        -- Exit insert mode
        jk = { "<esc>", desc = "Exit insert mode" },
        kj = { "<esc>", desc = "Exit insert mode" },
        jj = { "<esc>", desc = "Exit insert mode" },

        -- Clipboard paste
        ["<D-v>"] = { "<C-R>+", desc = "Paste from clipboard" },
      },
      t = {
        -- Clipboard in terminal
        ["<D-v>"] = { "<C-R>+", desc = "Paste from clipboard" },
      },
    },
  },
}
