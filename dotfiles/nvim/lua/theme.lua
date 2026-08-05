-- ~/.config/nvim/lua/theme.lua - Strict Monochrome Aesthetics

vim.cmd("highlight Clear")
if vim.fn.exists("syntax_on") then
    vim.cmd("syntax reset")
end

vim.g.colors_name = "monochrome"

local set_hl = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
end

set_hl("Normal", { fg = "#FFFFFF", bg = "#000000" })
set_hl("NormalFloat", { fg = "#FFFFFF", bg = "#111111" })
set_hl("CursorLine", { bg = "#1c1c1c" })
set_hl("LineNr", { fg = "#555555" })
set_hl("CursorLineNr", { fg = "#FFFFFF", bold = true })
set_hl("Comment", { fg = "#888888", italic = true })
set_hl("String", { fg = "#CCCCCC" })
set_hl("Function", { fg = "#FFFFFF", bold = true })
set_hl("Keyword", { fg = "#DDDDDD", bold = true })
set_hl("Visual", { bg = "#444444", fg = "#FFFFFF" })
set_hl("StatusLine", { fg = "#FFFFFF", bg = "#222222" })
set_hl("StatusLineNC", { fg = "#777777", bg = "#111111" })
