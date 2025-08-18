return {
	{
		"romgrk/barbar.nvim",
		dependencies = {
			"lewis6991/gitsigns.nvim", -- OPTIONAL: for git status
			"nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
		},
		init = function()
			vim.g.barbar_auto_setup = false
		end,
		opts = {
			icons = {
				modified = { button = "" }, -- button to close modified buffers
				pinned = { button = "車" }, -- button to pin/unpin buffers
				separator_at_end = false,
			},
		},
		version = "^1.0.0", -- optional: only update when a new 1.x version is released
	},
}
