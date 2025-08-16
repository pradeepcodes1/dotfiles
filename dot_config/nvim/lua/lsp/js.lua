-- lua/plugins/lsp/python.lua
local M = {}

---@param on_attach fun(client, bufnr)  -- your key-mapping callback
---@param capabilities table            -- usually from cmp_nvim_lsp
function M.setup(on_attach, capabilities)
  ---------------------------------------------------------------------------
  -- 1. Make sure Pyright is installed (Mason handles the download/update) --
  ---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  -- 2. Register the server with nvim-lspconfig ----------------------------
  ---------------------------------------------------------------------------
  require("lspconfig").ts_ls.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    -- settings = {
    --   python = {
    --     analysis = {
    --       -- adjust to taste; “basic” is lenient, “strict” is merciless 🙂
    --       typeCheckingMode = "basic",
    --       autoSearchPaths  = true,
    --       useLibraryCodeForTypes = true,
    --       diagnosticMode   = "openFilesOnly",
    --     },
    --   },
    -- },
  })
end

return M
