-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local vim = vim
local opt = vim.opt

-- opt.foldmethod = "expr"
-- opt.foldexpr = "nvim_treesitter#foldexpr()"
-- opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true
opt.foldnestmax = 20

opt.clipboard = "unnamedplus"

opt.cursorline = true
opt.spelllang = { "en", "cjk" }
-- opt.spell = true
opt.autochdir = true
