return {
	{
		"rcarriga/nvim-notify",
		config = function()
			require("notify").setup({
				background_colour = "#000000",
				stages = "static",
				timeout = 1500,
				minimum_width = 10,
				render = "minimal",
				top_down = true,
				icons = {
					ERROR = " ",
					WARN = " ",
					INFO = " ",
					DEBUG = " ",
					TRACE = "✎ ",
				},
			})
		end,
	},
}
