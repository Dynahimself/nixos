-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set

-- Directional keys (Home Row)
-- n = left, e = down, i = up, o = right
map({ "n", "v", "x" }, "n", "h", { desc = "Left" })
map({ "n", "v", "x" }, "e", "gj", { desc = "Down" }) -- gj handles wrapped lines
map({ "n", "v", "x" }, "i", "gk", { desc = "Up" }) -- gk handles wrapped lines
map({ "n", "v", "x" }, "o", "l", { desc = "Right" })

-- Visual Mode maps (needed for some edge cases)
map("v", "n", "h")
map("v", "e", "j")
map("v", "i", "k")
map("v", "o", "l")

-- k = search next, K = search prev (formerly n/N)
map({ "n", "v", "x" }, "k", "n", { desc = "Search next" })
map({ "n", "v", "x" }, "K", "N", { desc = "Search previous" })

-- j = end of word (formerly e)
map({ "n", "v", "x" }, "j", "e", { desc = "End of word" })
map({ "n", "v", "x" }, "J", "E", { desc = "End of word (space-delimited)" })

-- l = insert (formerly i), L = Insert at start of line (formerly I)
map("n", "l", "i", { desc = "Insert" })
map("n", "L", "I", { desc = "Insert at start of line" })

-- h = open line below (formerly o), H = open line above (formerly O)
map("n", "h", "o", { desc = "Open line below" })
map("n", "H", "O", { desc = "Open line above" })

-- Window navigation
map("n", "<C-n>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-e>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-i>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-o>", "<C-w>l", { desc = "Go to right window" })

-- Move through buffers using the new side-to-side keys (n/o)
map("n", "<S-n>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<S-o>", "<cmd>bnext<cr>", { desc = "Next buffer" })
