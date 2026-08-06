-- ~/.config/nvim/lua/lsp.lua - Native LSP Configuration

local servers = { "clangd", "pyright", "rust_analyzer", "ts_ls", "lua_ls" }

if vim.lsp.config then
    for _, lsp in ipairs(servers) do
        vim.lsp.config[lsp] = {}
        if vim.lsp.enable then
            vim.lsp.enable(lsp)
        end
    end
else
    local status_ok, lspconfig = pcall(require, "lspconfig")
    if status_ok then
        for _, lsp in ipairs(servers) do
            if lspconfig[lsp] then
                lspconfig[lsp].setup({})
            end
        end
    end
end
