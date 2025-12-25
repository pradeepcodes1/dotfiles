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
	vim.lsp.config("ts_ls", {
		on_attach = on_attach,
		capabilities = capabilities,
	})
	vim.lsp.enable("ts_ls")
end

return M
