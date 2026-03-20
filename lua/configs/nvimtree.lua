local options = {
  git = {
    enable = false,
  },
  renderer = {
    icons = {
      show = {
        git = false,
      },
    },
  },
  filesystem_watchers = {
    ignore_dirs = {
      "target",
      "node_modules",
    },
  },
}

return options