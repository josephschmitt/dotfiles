return {
  "neovim/nvim-lspconfig",
  opts = {
    setup = {
      vtsls = function(_, opts)
        -- Inject the HNVM_NODE variable so vtsls picks the right Node version.
        opts.cmd_env = {
          HVNM_QUIET = false, -- Ensure we log hnvm info in cases of failure.
          HNVM_NODE = "22.14.0", -- Update this version to match your hnvm setup.
        }
      end,
    },
  },
}
