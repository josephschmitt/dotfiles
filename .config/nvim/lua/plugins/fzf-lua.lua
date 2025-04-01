return {
  {
    "ibhagwan/fzf-lua",
    enabled = true,
    opts = {
      files = {
        hidden = true,
        fd_opts = [[--hidden --exclude .git --exclude node_modules --ignore-file ~/.fzfignore]],
      },
    },
  },
}
