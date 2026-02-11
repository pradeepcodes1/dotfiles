return {
	"folke/edgy.nvim",
	event = "VeryLazy",
	keys = {
		{
			"<leader>vs",
			function()
				-- Toggle symbol outline view
				vim.cmd("AerialToggle")
			end,
			desc = "View: Symbols",
		},
		{
			"<leader>vd",
			function()
				-- Toggle debug view
				require("dapui").toggle()
			end,
			desc = "View: Debug",
		},
		{
			"<leader>vc",
			function()
				-- Close all sidebars, return to clean coding view
				pcall(function()
					require("aerial").close_all()
				end)
				pcall(function()
					require("dapui").close()
				end)
				pcall(function()
					require("neotest").summary.close()
				end)
			end,
			desc = "View: Code (close all)",
		},
	},
	opts = {
		animate = { enabled = false },
		-- Left sidebar: symbol outline
		left = {
			{
				title = "Symbols",
				ft = "aerial",
				pinned = true,
				open = "AerialOpen",
				size = { width = 30 },
			},
		},
		-- Bottom panel: debug repl/console, quickfix, test output
		bottom = {
			{
				ft = "dap-repl",
				title = "REPL",
				size = { height = 12 },
			},
			{
				ft = "dapui_console",
				title = "Console",
				size = { height = 12 },
			},
			{
				ft = "qf",
				title = "Quickfix",
				size = { height = 10 },
			},
			{
				ft = "neotest-output-panel",
				title = "Test Output",
				size = { height = 15 },
			},
		},
		-- Right sidebar: debug panels
		right = {
			{
				ft = "dapui_scopes",
				title = "Scopes",
				size = { width = 60 },
			},
			{
				ft = "dapui_breakpoints",
				title = "Breakpoints",
				size = { width = 60 },
			},
			{
				ft = "dapui_stacks",
				title = "Stacks",
				size = { width = 60 },
			},
			{
				ft = "dapui_watches",
				title = "Watches",
				size = { width = 60 },
			},
		},
		-- Window options for sidebar windows
		wo = {
			winbar = true,
			winfixwidth = true,
			winfixheight = true,
			winhighlight = "WinBar:EdgyWinBar,Normal:EdgyNormal",
			signcolumn = "no",
			number = false,
			relativenumber = false,
			statusline = " ",
		},
	},
}
