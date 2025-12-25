return {
	"sphamba/smear-cursor.nvim",
	opts = {
		-- Cursor movement will smear with animation
		smear_between_buffers = true,
		smear_between_neighbor_lines = true,

		-- Increase fps for smoother animation (default is 60)
		legacy_computing_symbols_support = false,

		-- Smoother cursor movement
		stiffness = 0.8, -- Higher = less lag, more responsive (0.6-1.0)
		trailing_stiffness = 0.5, -- How fast the trail follows

		-- Distance from cursor before smear effect starts
		distance_stop_animating = 0.5,

		-- Hide the real cursor during smear animation
		hide_target_hack = false,
	},
}
