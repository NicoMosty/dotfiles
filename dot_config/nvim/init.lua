-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Load dynamic Matugen color theme if available
pcall(require, "config.matugen")
