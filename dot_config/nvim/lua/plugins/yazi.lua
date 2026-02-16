return {
	---@type LazySpec
	{
		"mikavilpas/yazi.nvim",
		version = "^12.0.0", -- pinned: v13+ requires yazi nightly (kebab-case events)
		event = "VeryLazy",
		dependencies = {
			{ "nvim-lua/plenary.nvim", lazy = true },
		},
		-- Keymaps defined in core/keymaps.lua
		---@type YaziConfig | {}
		opts = {
			open_for_directories = false,
			keymaps = {
				show_help = "<f1>",
			},
		},
		-- netrw is disabled in core/options.lua
	},
}
