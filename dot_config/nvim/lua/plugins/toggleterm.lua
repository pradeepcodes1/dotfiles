return {
	"akinsho/toggleterm.nvim",
	version = "*", -- or a specific version tag
	config = function()
		require("toggleterm").setup({
			direction = "float",
			float_opts = {
				border = "single", -- 'single', 'double', 'shadow', 'curved'
			},
		})

		-- Function to toggle a dedicated lazygit terminal
		local lazygit_toggle
		do
			local Terminal = require("toggleterm.terminal").Terminal
			local lazygit_term = Terminal:new({
				cmd = "lazygit",
				dir = "git_dir", -- Opens in the project's git root
				hidden = true, -- Hide it on startup
				direction = "float",
				float_opts = {
					border = "double", -- Differentiate it visually
				},
				close_on_exit = true,
				-- When the terminal closes, refresh file status
				on_close = function(_)
					vim.cmd("checktime")
				end,
			})

			lazygit_toggle = function()
				lazygit_term:toggle()
			end
		end

		-- Map a key to the lazygit toggle function
		vim.keymap.set("n", "<leader>gg", lazygit_toggle, { desc = "Toggle lazygit" })
	end,
}
