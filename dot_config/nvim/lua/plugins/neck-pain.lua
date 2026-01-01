return {
	{
		"shortcuts/no-neck-pain.nvim",
		version = "*",
		lazy = false,
		config = function()
			require("no-neck-pain").setup({
				width = 140,
				autocmds = {
					enableOnVimEnter = false,
					enableOnTabEnter = false,
					skipEnteringNoNeckPainBuffer = true,
				},
			})

			-- Enable only for specific filetypes
			local allowed_filetypes = {
				"lua",
				"python",
				"javascript",
				"typescript",
				"typescriptreact",
				"javascriptreact",
				"go",
				"rust",
				"markdown",
				"text",
			}

			vim.api.nvim_create_autocmd("FileType", {
				pattern = allowed_filetypes,
				callback = function()
					local nnp = require("no-neck-pain")
					if not nnp.state or not nnp.state.enabled then
						vim.cmd("NoNeckPain")
					end
				end,
			})
		end,
	},
}
