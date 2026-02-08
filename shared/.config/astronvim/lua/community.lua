-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  -- Colorschemes
  { import = "astrocommunity.colorscheme.catppuccin" },
  { import = "astrocommunity.colorscheme.tokyonight-nvim" },

  -- Language packs
  { import = "astrocommunity.pack.lua" },

  -- Motion
  { import = "astrocommunity.motion.flash-nvim" },
  { import = "astrocommunity.motion.mini-move" },
  { import = "astrocommunity.motion.mini-bracketed" },

  -- Editing support
  { import = "astrocommunity.editing-support.mini-splitjoin" },

  -- File explorer
  { import = "astrocommunity.file-explorer.yazi-nvim" },

  -- Diagnostics
  { import = "astrocommunity.diagnostics.tiny-inline-diagnostic-nvim" },

  -- Git
  { import = "astrocommunity.git.mini-diff" },
  { import = "astrocommunity.git.diffview-nvim" },

  -- Completion
  { import = "astrocommunity.completion.cmp-cmdline" },

  -- import/override with your plugins folder
}
