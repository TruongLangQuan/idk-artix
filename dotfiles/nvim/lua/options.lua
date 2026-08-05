-- ~/.config/nvim/lua/options.lua - Core Neovim Options

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.wrap = false
opt.ignorecase = true
opt.smartcase = true
opt.termguicolors = true
opt.scrolloff = 8
opt.signcolumn = "yes"
opt.updatetime = 50
opt.completeopt = { "menuone", "noselect" }
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true
opt.cursorline = true
