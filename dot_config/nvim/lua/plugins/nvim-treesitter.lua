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
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<CR>",
					node_incremental = "<Tab>",
					node_decremental = "<S-Tab>",
					scope_incremental = false,
				},
			},
		})
	end,
}
