local common = require("lsp.common")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

return {
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "ts_ls", "lua_ls", "clangd", "gopls", "rust_analyzer" },

				handlers = {
					function(server_name) -- default handler (optional)
						print("TESTING: " .. server_name)
						vim.notify("Setting up LSP: " .. server_name, vim.log.levels.INFO)
						vim.lsp.config(server_name, {
							on_attach = common.on_attach,
							capabilities = capabilities,
							handlers = {
								["$/progress"] = function() end, -- disable progress notifications
							},
						})
						vim.lsp.enable(server_name)
					end,
					jdtls = function() end,
				},
			})
		end,
	},
}
