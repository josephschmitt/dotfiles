-- celeste_comment.nvim: replaces Neovim's built-in commenting (`vim._comment`).
--
-- What it adds over the built-in:
--   * Block comments (`gb` / `gbc`) — the built-in only does line comments
--   * Sticky cursor/selection — position tracks each edit instead of jumping to
--     the start of the commented range
--   * Tree-sitter-aware comment strings — correct markers inside JSX/TSX, Vue, etc.
--   * VSCode-style indent handling for buffers that mix tabs and spaces
--
-- Requires Neovim 0.12+, so it's version-gated: on 0.11 the `cond` is false, the
-- plugin never loads, and the built-in `gc`/`gcc` mappings stay in place.
-- Pinned to `~0.3.0` (patch updates only) — upstream ships breaking changes in
-- MINOR bumps.
return {
  {
    "celeste3z/celeste_comment.nvim",
    version = "~0.3.0",
    cond = vim.fn.has("nvim-0.12") == 1,
    -- Loaded on first use. `o` mode covers the textobjects (e.g. `dgc` deletes a
    -- comment block); `<C-c>` in keymaps.lua feeds `gcc`, which trips this too.
    keys = {
      { "gc", mode = { "n", "x", "o" }, desc = "Toggle comment" },
      { "gcc", desc = "Toggle comment line" },
      { "gb", mode = { "n", "x", "o" }, desc = "Toggle block comment" },
      { "gbc", desc = "Toggle block comment line" },
      { "gco", desc = "Comment below" },
      { "gcO", desc = "Comment above" },
      { "gcA", desc = "Comment end of line" },
    },
    opts = {
      mappings = {
        -- Off by default upstream; enabled here to match AstroNvim/LazyVim muscle
        -- memory for adding a fresh comment line without leaving normal mode.
        line_add_below = "gco",
        line_add_above = "gcO",
        line_add_eol = "gcA",
      },
    },
  },
}
