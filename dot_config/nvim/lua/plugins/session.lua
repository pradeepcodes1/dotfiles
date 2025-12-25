return {
	"rmagatti/auto-session",
	lazy = false,
	keys = {
		-- Will use Telescope if installed or a vim.ui.select picker otherwise
		{ "<leader>sr", "<cmd>AutoSession search<CR>", desc = "Session search" },
		{ "<leader>ss", "<cmd>AutoSession save<CR>", desc = "Save session" },
		{ "<leader>sa", "<cmd>AutoSession autosave toggle<CR>", desc = "Toggle autosave" },
	},

	---enables autocomplete for opts
	---@module "auto-session"
	---@type AutoSession.Config
	opts = {
		-- Disable auto-restore to prevent unexpected session reloading
		-- when opening files outside the current folder (issue #129)
		auto_restore = false,
		-- Automatically create session files for new directories
		auto_create = true,
		-- Automatically save session on exit
		auto_save = true,
		-- Use git branch name in session file name
		git_use_branch_name = true,
		-- Suppress session creation/restoration in these directories
		suppressed_dirs = {
			"~/",
			"~/Downloads",
			"~/Desktop",
			"~/Documents",
			"/tmp",
			"/",
		},
		-- Handle cwd changes by updating session
		cwd_change_handling = true,
		-- Automatically delete sessions with only empty/unnamed buffers
		auto_delete_empty_sessions = true,
		-- Don't auto-save when these file types are the only ones open
		bypass_save_filetypes = { "alpha", "dashboard", "lazy" },

		session_lens = {
			mappings = {
				-- Mode can be a string or a table, e.g. {"i", "n"} for both insert and normal mode
				delete_session = { "i", "<C-D>" },
				alternate_session = { "i", "<C-S>" },
				copy_session = { "i", "<C-Y>" },
			},

			picker_opts = {
				-- For Telescope, you can set theme options here, see:
				-- https://github.com/nvim-telescope/telescope.nvim/blob/master/doc/telescope.txt#L112
				-- https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/themes.lua
				--
				-- border = true,
				-- layout_config = {
				--   width = 0.8, -- Can set width and height as percent of window
				--   height = 0.5,
				-- },

				-- For Snacks, you can set layout options here, see:
				-- https://github.com/folke/snacks.nvim/blob/main/docs/picker.md#%EF%B8%8F-layouts
				--
				-- preset = "dropdown",
				-- preview = false,
				-- layout = {
				--   width = 0.4,
				--   height = 0.4,
				-- },
			},

			-- Telescope only: If load_on_setup is false, make sure you use `:SessionSearch` to open the picker as it will initialize everything first
			load_on_setup = true,
		},
	},
}
