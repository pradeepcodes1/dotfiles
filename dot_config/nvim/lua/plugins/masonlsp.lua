local common = require("lsp.common")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Set global LSP defaults (capabilities, progress handler)
vim.lsp.config("*", {
	capabilities = capabilities,
	handlers = {
		["$/progress"] = function() end,
	},
})

-- Set up LSP keymaps via LspAttach autocommand
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client then
			common.on_attach(client, ev.buf)
			if client.name == "jdtls" then
				require("lsp.java").on_attach(ev.buf)
			end
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
					"lemminx",
				},
				automatic_enable = {
					exclude = { "jdtls" },
				},
			})
		end,
	},
}
