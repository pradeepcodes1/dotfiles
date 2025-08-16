return {
	-- lazy.nvim
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			-- add any options here
		},
		dependencies = {
			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
			"MunifTanjim/nui.nvim",
			-- OPTIONAL:
			--   `nvim-notify` is only needed, if you want to use the notification view.
			--   If not available, we use `mini` as the fallback
			"rcarriga/nvim-notify",
		},
		config = function()
			require("noice").setup({
				-- add any options here
				{
					level = 2,
					minimum_width = 50,
					render = "minimal",
					stages = "fade_in_slide_out",
					time_formats = {
						notification = "%T",
						notification_history = "%FT%T",
					},
					timeout = 5000,
					top_down = true,
				},
			})
		end,
	},
}
