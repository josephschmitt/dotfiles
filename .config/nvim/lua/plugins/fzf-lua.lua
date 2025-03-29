return {
  {
    "ibhagwan/fzf-lua",
    enabled = true,
    opts = {
      files = {
        fd_opts = [[--hidden --exclude .git --exclude node_modules --ignore-file ~/.fzfignore]],
      },
    },
  },
}
