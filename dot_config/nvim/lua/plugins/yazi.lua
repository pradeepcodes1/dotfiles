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
		-- 👇 if you use `open_for_directories=true`, this is recommended
		init = function()
			-- mark netrw as loaded so it's not loaded at all.
			--
			-- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
			vim.g.loaded_netrwPlugin = 1
		end,
	},
}
