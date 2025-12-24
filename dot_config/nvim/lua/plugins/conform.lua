return {
	{
		"stevearc/conform.nvim",
		opts = {},
		enabled = true,
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					lua = { "stylua" },
					python = { "black" },
					javascript = { "prettier" },
					typescript = { "prettier" },
					html = { "prettier" },
					css = { "prettier" },
					cpp = { "clang-format" },
					go = { "gofmt" },
					rust = { "rustfmt" },
					json = { "prettier" },
					yaml = { "prettier" },
					markdown = { "prettier" },
					toml = { "taplo" },
				},
				format_on_save = {
					-- These options will be passed to conform.format()
					timeout_ms = 500,
					lsp_format = "fallback",
				},
			})
		end,
	},
}
