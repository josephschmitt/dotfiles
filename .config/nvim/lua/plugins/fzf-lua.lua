return {
  {
    "ibhagwan/fzf-lua",
    enabled = false,
    opts = {
      files = {
        fd_opts = [[--hidden --exclude .git --exclude node_modules --ignore-file ~/.fzfignore]],
      },
    },
  },
}
