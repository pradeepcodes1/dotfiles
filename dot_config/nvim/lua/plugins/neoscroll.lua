return {
	"karb94/neoscroll.nvim",
	event = "VeryLazy",
	config = function()
		local neoscroll = require("neoscroll")
		neoscroll.setup({
			mappings = {},
			hide_cursor = true,
			stop_eof = true,
			respect_scrolloff = false,
			cursor_scrolls_alone = false,
			easing_function = "quadratic",
		})

		local modes = { "n", "v", "x" }
		local map = vim.keymap.set
		map(modes, "<ScrollWheelUp>", function()
			neoscroll.scroll(-5, { move_cursor = true, duration = 100 })
		end)
		map(modes, "<ScrollWheelDown>", function()
			neoscroll.scroll(5, { move_cursor = true, duration = 100 })
		end)
		map(modes, "<C-u>", function()
			neoscroll.ctrl_u({ duration = 150 })
		end)
		map(modes, "<C-d>", function()
			neoscroll.ctrl_d({ duration = 150 })
		end)
		map(modes, "<C-b>", function()
			neoscroll.ctrl_b({ duration = 250 })
		end)
		map(modes, "<C-f>", function()
			neoscroll.ctrl_f({ duration = 250 })
		end)
		map(modes, "<C-y>", function()
			neoscroll.scroll(-0.1, { move_cursor = false, duration = 50 })
		end)
		map(modes, "<C-e>", function()
			neoscroll.scroll(0.1, { move_cursor = false, duration = 50 })
		end)
		map(modes, "zt", function()
			neoscroll.zt({ half_win_duration = 100 })
		end)
		map(modes, "zz", function()
			neoscroll.zz({ half_win_duration = 100 })
		end)
		map(modes, "zb", function()
			neoscroll.zb({ half_win_duration = 100 })
		end)
	end,
}
