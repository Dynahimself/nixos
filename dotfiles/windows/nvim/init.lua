-- Dyna's lightweight native Windows Neovim config (Colemak-DH + Catppuccin Mocha palette)
-- Mirrors Nixvim muscle memory for quick Windows-side edits with zero external plugin overhead.

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.termguicolors = true
opt.clipboard = "unnamedplus"
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.smartindent = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.splitright = true
opt.splitbelow = true
opt.updatetime = 200
opt.timeoutlen = 300
opt.wrap = false

-- Catppuccin Mocha built-in highlight skin (zero plugin dependency)
vim.cmd("highlight clear")
vim.o.background = "dark"
local hl = function(g, opts) vim.api.nvim_set_hl(0, g, opts) end
hl("Normal",       { fg = "#cdd6f4", bg = "NONE" })
hl("NormalFloat",  { fg = "#cdd6f4", bg = "#181825" })
hl("FloatBorder",  { fg = "#cba6f7", bg = "#181825" })
hl("CursorLine",   { bg = "#313244" })
hl("CursorLineNr", { fg = "#cba6f7", bold = true })
hl("LineNr",       { fg = "#6c7086" })
hl("Visual",       { bg = "#45475a" })
hl("Search",       { fg = "#11111b", bg = "#f9e2af" })
hl("IncSearch",    { fg = "#11111b", bg = "#fab387", bold = true })
hl("StatusLine",   { fg = "#cdd6f4", bg = "#181825" })
hl("StatusLineNC", { fg = "#6c7086", bg = "#11111b" })
hl("Comment",      { fg = "#6c7086", italic = true })
hl("String",       { fg = "#a6e3a1" })
hl("Number",       { fg = "#fab387" })
hl("Keyword",      { fg = "#cba6f7", bold = true })
hl("Function",     { fg = "#89b4fa", bold = true })
hl("Type",         { fg = "#f9e2af" })
hl("Identifier",   { fg = "#f2cdcd" })
hl("DiagnosticError", { fg = "#f38ba8" })
hl("DiagnosticWarn",  { fg = "#f9e2af" })
hl("DiagnosticInfo",  { fg = "#89b4fa" })
hl("DiagnosticHint",  { fg = "#94e2d5" })

local map = vim.keymap.set
-- Directional Colemak-DH (n/e/i/o = h/j/k/l)
map({ "n", "x", "o" }, "n", "h", { desc = "Left" })
map({ "n", "x" },      "e", "gj", { desc = "Down" })
map("o",               "e", "j", { desc = "Down" })
map({ "n", "x" },      "i", "gk", { desc = "Up" })
map("o",               "i", "k", { desc = "Up" })
map({ "n", "x", "o" }, "o", "l", { desc = "Right" })

-- Displaced builtins
map("n",               "l", "i", { desc = "Insert" })
map({ "n", "x" },      "L", "I", { desc = "Insert at line start" })
map({ "x", "o" },      "l", "i", { desc = "Inner text object" })
map("n",               "gl", "gi", { desc = "Insert at last pos" })
map("n",               "h", "o", { desc = "Open line below" })
map("n",               "H", "O", { desc = "Open line above" })
map("x",               "h", "o", { desc = "Other end of selection" })
map({ "n", "x", "o" }, "j", "e", { desc = "End of word" })
map({ "n", "x", "o" }, "J", "E", { desc = "End of WORD" })
map({ "n", "x" },      "gJ", "J", { desc = "Join lines" })
map("n",               "k", "nzzzv", { desc = "Search next (centered)" })
map("n",               "K", "Nzzzv", { desc = "Search prev (centered)" })
map({ "x", "o" },      "k", "n", { desc = "Search next" })
map({ "x", "o" },      "K", "N", { desc = "Search prev" })
map("n",               "<C-d>", "<C-d>zz")
map("n",               "<C-u>", "<C-u>zz")

-- Window & Buffer nav
map("n", "<C-n>", "<C-w>h")
map("n", "<C-e>", "<C-w>j")
map("n", "<C-i>", "<C-w>k")
map("n", "<C-o>", "<C-w>l")
map("n", "<S-n>", "<cmd>bprevious<cr>")
map("n", "<S-o>", "<cmd>bnext<cr>")
map("n", "<A-e>", "<cmd>execute 'move .+' . v:count1<cr>==")
map("n", "<A-i>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==")
map("n", "<Esc>", "<cmd>nohlsearch<cr>")
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit" })

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.highlight.on_yank({ timeout = 160 }) end,
})
