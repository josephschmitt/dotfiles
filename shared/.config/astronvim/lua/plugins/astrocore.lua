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

        -- Explorer keymaps (Neo-tree and Yazi)
        ["<Leader>ee"] = { "<Cmd>Neotree toggle<CR>", desc = "Toggle Explorer (current file)" },
        ["<Leader>eE"] = { "<Cmd>Neotree toggle dir=<CR>", desc = "Toggle Explorer (cwd)" },
        ["<Leader>eb"] = { "<Cmd>Neotree buffers<CR>", desc = "Buffer Explorer" },
        ["<Leader>eg"] = { "<Cmd>Neotree git_status<CR>", desc = "Git Explorer" },

        -- Git diff
        ["<Leader>gd"] = {
          function() require("mini.diff").toggle_overlay() end,
          desc = "View Git diff (unstaged)",
        },
        ["<Leader>gD"] = {
          function()
            local MiniDiff = require("mini.diff")
            if vim.b.minidiff_showing_head then
              vim.b.minidiff_showing_head = false
              MiniDiff.disable()
              MiniDiff.enable()
            else
              vim.b.minidiff_showing_head = true
              local file = vim.api.nvim_buf_get_name(0)
              local relative_path = vim.fn.fnamemodify(file, ":.")
              local head_content = vim.fn.system("git show HEAD:" .. vim.fn.shellescape(relative_path))

              if vim.v.shell_error == 0 then
                MiniDiff.set_ref_text(0, head_content)
                local buf_data = MiniDiff.get_buf_data()
                if buf_data and not buf_data.overlay then
                  vim.defer_fn(function() MiniDiff.toggle_overlay() end, 50)
                end
              else
                vim.notify("Could not get HEAD version of file", vim.log.levels.WARN)
              end
            end
          end,
          desc = "View Git diff (staged)",
        },

        -- Save
        ["<Leader>s"] = { "<Cmd>w<CR>", desc = "Save buffer" },

        -- Smart picker
        ["<Leader><Space>"] = {
          function() require("snacks").picker.smart() end,
          desc = "Smart picker",
        },

        -- Project pickers
        ["<Leader>fp"] = { "<cmd>Pj<cr>", desc = "Find Projects (pj)" },
        ["<Leader>fP"] = {
          function() require("snacks").picker.projects() end,
          desc = "Find Projects (snacks)",
        },

        -- Goto
        gh = { "0", desc = "Go to beginning of line" },
        gl = { "$", desc = "Go to end of line" },

        -- Window
        gw = { "<C-w>", desc = "Window mode" },
        ["<A-w>"] = { "<C-w>w", desc = "Switch window" },

        -- Window group
        ["<Leader>w"] = { desc = " Window" },

        -- Split creation
        ["<Leader>ws"] = { "<Cmd>split<CR>", desc = "Split horizontal" },
        ["<Leader>wv"] = { "<Cmd>vsplit<CR>", desc = "Split vertical" },

        -- Window closing/management
        ["<Leader>wc"] = { "<Cmd>close<CR>", desc = "Close window" },
        ["<Leader>wo"] = { "<Cmd>only<CR>", desc = "Close other windows" },
        ["<Leader>w="] = { "<C-w>=", desc = "Equalize window sizes" },

        -- Window movement (move current window to position)
        ["<Leader>wH"] = { "<C-w>H", desc = "Move window left" },
        ["<Leader>wJ"] = { "<C-w>J", desc = "Move window down" },
        ["<Leader>wK"] = { "<C-w>K", desc = "Move window up" },
        ["<Leader>wL"] = { "<C-w>L", desc = "Move window right" },
        ["<Leader>wr"] = { "<C-w>r", desc = "Rotate windows" },
        ["<Leader>wx"] = { "<C-w>x", desc = "Swap with next window" },

        -- Window resizing
        ["<Leader>w+"] = { "<Cmd>resize +5<CR>", desc = "Increase height" },
        ["<Leader>w-"] = { "<Cmd>resize -5<CR>", desc = "Decrease height" },
        ["<Leader>w>"] = { "<Cmd>vertical resize +5<CR>", desc = "Increase width" },
        ["<Leader>w<lt>"] = { "<Cmd>vertical resize -5<CR>", desc = "Decrease width" },

        -- Tab group
        ["<Leader><Tab>"] = { desc = "➡ Tabs" },

        -- Tab creation/closing
        ["<Leader><Tab>n"] = { "<Cmd>tabnew<CR>", desc = "New tab" },
        ["<Leader><Tab>c"] = { "<Cmd>tabclose<CR>", desc = "Close tab" },
        ["<Leader><Tab>o"] = { "<Cmd>tabonly<CR>", desc = "Close other tabs" },

        -- Tab navigation
        ["<Leader><Tab>]"] = { "<Cmd>tabnext<CR>", desc = "Next tab" },
        ["<Leader><Tab>["] = { "<Cmd>tabprevious<CR>", desc = "Previous tab" },
        ["<Leader><Tab>l"] = { "<Cmd>tablast<CR>", desc = "Last tab" },
        ["<Leader><Tab>f"] = { "<Cmd>tabfirst<CR>", desc = "First tab" },

        -- Tab movement
        ["<Leader><Tab>>"] = { "<Cmd>+tabmove<CR>", desc = "Move tab right" },
        ["<Leader><Tab><lt>"] = { "<Cmd>-tabmove<CR>", desc = "Move tab left" },

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
        ["<Leader>bD"] = {
          function() require("astrocore.buffer").close() end,
          desc = "Close current buffer",
        },
        ["<Leader>ba"] = {
          function() require("astrocore.buffer").close_all() end,
          desc = "Close all buffers",
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
