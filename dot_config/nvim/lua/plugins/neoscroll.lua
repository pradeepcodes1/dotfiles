return {
	"karb94/neoscroll.nvim",
	config = function()
		require("neoscroll").setup({
			-- All these keys will be mapped to their corresponding default scrolling animation
			mappings = {},
			hide_cursor = true, -- Hide cursor while scrolling
			stop_eof = true, -- Stop at <EOF> when scrolling downwards
			respect_scrolloff = false, -- Stop scrolling when the cursor reaches the scrolloff margin of the file
			cursor_scrolls_alone = false, -- Don't allow cursor to scroll past window boundaries
			easing_function = "quadratic", -- Default easing function (sine, circular, quadratic, cubic, quartic)
			pre_hook = nil, -- Function to run before the scrolling animation starts
			post_hook = nil, -- Function to run after the scrolling animation ends
			performance_mode = false, -- Disable "Performance Mode" on all buffers.
		})

		-- Custom scroll mappings for even smoother experience
		local neoscroll = require("neoscroll")
		local keymap = {
			-- Mouse wheel scrolling
			["<ScrollWheelUp>"] = function()
				neoscroll.scroll(-5, { move_cursor = true, duration = 100 })
			end,
			["<ScrollWheelDown>"] = function()
				neoscroll.scroll(5, { move_cursor = true, duration = 100 })
			end,
			-- Keyboard scrolling
			["<C-u>"] = function()
				neoscroll.ctrl_u({ duration = 150 })
			end,
			["<C-d>"] = function()
				neoscroll.ctrl_d({ duration = 150 })
			end,
			["<C-b>"] = function()
				neoscroll.ctrl_b({ duration = 250 })
			end,
			["<C-f>"] = function()
				neoscroll.ctrl_f({ duration = 250 })
			end,
			["<C-y>"] = function()
				neoscroll.scroll(-0.1, { move_cursor = false, duration = 50 })
			end,
			["<C-e>"] = function()
				neoscroll.scroll(0.1, { move_cursor = false, duration = 50 })
			end,
			["zt"] = function()
				neoscroll.zt({ half_win_duration = 100 })
			end,
			["zz"] = function()
				neoscroll.zz({ half_win_duration = 100 })
			end,
			["zb"] = function()
				neoscroll.zb({ half_win_duration = 100 })
			end,
		}
		local modes = { "n", "v", "x" }
		for key, func in pairs(keymap) do
			vim.keymap.set(modes, key, func)
		end
	end,
}
