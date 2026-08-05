-- ~/.config/nvim/lua/lsp.lua - Native LSP Configuration

local status_ok, lspconfig = pcall(require, "lspconfig")
if not status_ok then
    return
end

local servers = { "clangd", "pyright", "rust_analyzer", "ts_ls", "lua_ls" }

for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup({})
end
