local common = require("lsp.common")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Set up LSP keymaps via LspAttach autocommand (required for vim.lsp.config API)
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client then
			common.on_attach(client, ev.buf)
		end
	end,
})

return {
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"ts_ls",
					"lua_ls",
					"clangd",
					"gopls",
					"rust_analyzer",
					"pyright",
					"jsonls",
					"yamlls",
					"marksman",
					"tailwindcss",
				},

				handlers = {
					function(server_name) -- default handler (optional)
						vim.lsp.config(server_name, {
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
