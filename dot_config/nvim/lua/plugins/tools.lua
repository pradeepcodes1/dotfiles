return {
	{
		"nvimtools/none-ls.nvim",
		dependencies = { "nvimtools/none-ls-extras.nvim" },
		enabled = false,
		opts = function()
			local nls = require("null-ls")
			nls.setup({
				sources = {
					require("none-ls.diagnostics.ruff"),
					nls.builtins.formatting.google_java_format,
				},
			})
		end,
	},
}
