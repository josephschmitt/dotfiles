return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    local function cwd()
      return vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
    end

    opts.sections.lualine_x = {
      { cwd, icon = "" },
    }

    return opts
  end,
}
