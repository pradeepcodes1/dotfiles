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
		-- Keymaps defined in core/keymaps.lua
	end,
}
