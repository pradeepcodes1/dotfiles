local common = require("lsp.common")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

return {
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "ts_ls", "lua_ls", "jdtls", "clangd" },

				handlers = {
					function(server_name) -- default handler (optional)
						require("lspconfig")[server_name].setup({
							on_attach = common.on_attach,
							capabilities = capabilities,
						})
					end,
				},
			})
		end,
	},
}
