return {
	-- lazy.nvim
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {},
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		config = function()
			require("noice").setup({
				lsp = {
					progress = {
						enabled = false,
					},
				},
				routes = {
					{
						filter = {
							event = "notify",
							find = "No results from textDocument/documentSymbol",
						},
						opts = { skip = true },
					},
					{
						filter = {
							event = "lsp",
							kind = "message",
						},
						opts = { skip = true },
					},
				},
			})
		end,
	},
}
