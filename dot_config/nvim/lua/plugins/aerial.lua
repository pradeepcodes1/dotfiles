return {
	"stevearc/aerial.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	cmd = { "AerialToggle", "AerialOpen" },
	opts = {
		backends = { "lsp", "treesitter", "markdown", "man" },
		layout = {
			default_direction = "left",
			min_width = 30,
			max_width = 40,
		},
		attach_mode = "global",
		filter_kind = false,
		show_guides = true,
		guides = {
			mid_item = "├ ",
			last_item = "└ ",
			nested_top = "│ ",
			whitespace = "  ",
		},
		highlight_on_hover = true,
		autojump = true,
		close_on_select = false,
		keymaps = {
			["<CR>"] = "actions.jump",
			["<C-v>"] = "actions.jump_vsplit",
			["<C-s>"] = "actions.jump_split",
			["q"] = "actions.close",
			["o"] = "actions.tree_toggle",
		},
	},
}
