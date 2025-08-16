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

		-- Custom function to set keymaps specifically for terminal buffers
		function _G.set_terminal_keymaps()
			local opts = { buffer = 0 }
			-- Use 'jk' to exit terminal mode
			vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
			-- Close the terminal with the same key used to open it
			vim.keymap.set("t", "<leader>t", [[<Cmd>ToggleTerm<CR>]], opts)
		end

		-- Use an autocommand to run the function when a terminal is opened
		vim.api.nvim_create_autocmd("TermOpen", {
			pattern = "term://*",
			callback = function()
				set_terminal_keymaps()
			end,
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
		vim.keymap.set("n", "<leader>tg", lazygit_toggle, { desc = "Toggle lazygit" })
	end,
}
