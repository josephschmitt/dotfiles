-- Enable blink.cmp command-line completion with auto-show.
-- blink.cmp has built-in cmdline support (no extra plugins needed).
-- This makes the completion menu appear automatically when typing : commands.
return {
  {
    "saghen/blink.cmp",
    opts = {
      cmdline = {
        completion = { menu = { auto_show = true } },
      },
    },
  },
}
