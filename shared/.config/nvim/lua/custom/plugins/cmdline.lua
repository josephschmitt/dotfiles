-- Enable blink.cmp command-line completion with auto-show.
-- blink.cmp has built-in cmdline support (no extra plugins needed).
-- This makes the completion menu appear automatically when typing : commands.
return {
  {
    "saghen/blink.cmp",
    opts = {
      cmdline = {
        completion = { menu = { auto_show = true } },
        keymap = {
          preset = "super-tab",
          -- Extra muscle-memory aliases for select_prev/select_next, on top of
          -- what "super-tab" already gives you (Up/Down, Ctrl-p/Ctrl-n).
          -- "fallback" means: if the menu has nothing to select, run the
          -- normal cmdline binding instead (Ctrl-u clears the line, Ctrl-d
          -- lists matches) — so you only lose those when the menu is open.
          ["<C-d>"] = { "select_next", "fallback" },
          ["<C-u>"] = { "select_prev", "fallback" },
        },
      },
    },
  },
}
