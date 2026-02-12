-- pj.nvim: project navigation using the pj binary.
-- Fuzzy-find and switch between projects with <Leader>fp.
-- Uses Snacks picker for the UI.
return {
  {
    "josephschmitt/pj.nvim",
    dependencies = { "folke/snacks.nvim" },
    cmd = { "Pj", "PjCd" },
    keys = {
      { "<Leader>fp", "<Cmd>Pj<CR>", desc = "Find Projects (pj)" },
    },
    opts = {
      pj = { cmd = "auto" },
      picker = { type = "snacks" },
    },
  },
}
