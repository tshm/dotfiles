-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

--local Util = require("lazyvim.util")

local function map(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  -- do not create the keymap if a lazy keys handler exists
  if not keys.active[keys.parse({ lhs, mode = mode }).id] then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

vim.keymap.del("n", "<Leader>gf") -- delete lazygit keymaps
vim.keymap.del("n", "<Leader>gG") -- delete lazygit keymaps

map("n", "<leader><space>", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })

if vim.g.vscode then
  map("n", "zR", "<cmd>call VSCodeNotify('editor.unfoldAll')<CR>")
  map("n", "zc", "<cmd>call VSCodeNotify('editor.fold')<CR>")
  map("n", "zC", "<cmd>call VSCodeNotify('editor.foldRecursively')<CR>")
  map("n", "zo", "<cmd>call VSCodeNotify('editor.unfold')<CR>")
  map("n", "zO", "<cmd>call VSCodeNotify('editor.unfoldRecursively')<CR>")
  map("n", "za", "<cmd>call VSCodeNotify('editor.toggleFold')<CR>")

  map("n", "j", "<cmd>call VSCodeNotify('cursorDown')<CR>")
  map("n", "k", "<cmd>call VSCodeNotify('cursorUp')<CR>")
else
end
