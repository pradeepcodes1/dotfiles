---@module "lazy"
---@type LazySpec
return {
	"nvim-treesitter/nvim-treesitter",
	branch = "master",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"lua",
				"cpp",
				"python",
				"java",
				"json",
				"yaml",
				"bash",
				"javascript",
				"go",
				"proto",
			},
			highlight = { enable = true },
		})
	end,
}
