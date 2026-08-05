-- ~/.config/nvim/lua/keymaps.lua - Keybindings

vim.g.mapleader = " "

local map = vim.keymap.set

map("n", "<leader>pv", vim.cmd.Ex, { desc = "File Explorer" })
map("n", "<leader>w", ":w<CR>", { desc = "Save File" })
map("n", "<leader>q", ":q<CR>", { desc = "Quit File" })

-- Clear highlights
map("n", "<ESC>", ":noh<CR>", { silent = true })

-- Terminal navigation
map("t", "<Esc>", "<C-\\><C-n>")
