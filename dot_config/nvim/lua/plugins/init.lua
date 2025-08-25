return {
	----------------------------------------
	-- Core UX
	----------------------------------------
	{ "nvim-lua/plenary.nvim" }, -- lua helpers
	{ "nvim-tree/nvim-web-devicons" },
	{ "folke/which-key.nvim", event = "VeryLazy", config = true },
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.6",
		dependencies = { "plenary.nvim" },
		opts = {
			defaults = {
				file_ignore_patterns = { "node_modules", ".git", "build" },
			},
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"lua",
					"cpp",
					"python",
					"java",
					"json",
					"yaml",
					"bash",
					"javascript",
					"go",
					"proto",
				},
				highlight = { enable = true },
			})
		end,
	},
	----------------------------------------
	-- Git & coding aids
	----------------------------------------
	{ "lewis6991/gitsigns.nvim", event = "BufReadPre", config = true },
	{ "windwp/nvim-autopairs", event = "InsertEnter", config = true },
	{ "numToStr/Comment.nvim", event = "VeryLazy", config = true },

	----------------------------------------
	-- LSP, diagnostics, formatting
	----------------------------------------
	{
		"nvim-java/nvim-java",
		config = function()
			require("java").setup({
				jdtls = {
					cmd = { "jdtls" },
					handlers = {
						["$/progress"] = function() end, -- disable progress notifications
					},
				},
			})
			require("lspconfig").jdtls.setup({
				handlers = {
					["$/progress"] = function() end,
				},
			})
		end,
	},

	{ "neovim/nvim-lspconfig", dependencies = {
		"nvim-java/nvim-java",
	} },
	{ "j-hui/fidget.nvim", tag = "legacy", config = true },
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
		},
	},

	----------------------------------------
	-- Java specifics
	----------------------------------------
	-- { "mfussenegger/nvim-jdtls" },

	----------------------------------------
	-- Python specifics
	----------------------------------------
	{ "linux-cultist/venv-selector.nvim", cmd = "VenvSelect", opts = { search_venv_managers = false } },

	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {
			-- Put all settings here
			indent = { char = "┊" },
			scope = { enabled = false },
			whitespace = { remove_blankline_trail = false },
			exclude = {
				filetypes = {
					"dashboard",
					"help",
					"lazy",
					"mason",
					"neo-tree", -- good to add this one too
				},
			},
		},
		-- Remove the config function entirely
	},
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
		opts = {},
	},
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		---@type snacks.Config
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
			bigfile = { enabled = true },
			dashboard = {
				enabled = true,
				preset = {
					keys = {
						{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },

						{
							icon = " ",
							key = "f",
							desc = "Find File",
							action = "<leader>ff",
						},

						{
							icon = " ",
							key = "g",
							desc = "Find Text",
							action = "<leader>fg",
						},
						{
							icon = " ",
							key = "r",
							desc = "Recent Files",
							action = ":lua Snacks.dashboard.pick('oldfiles')",
						},
						{ icon = "", key = "p", desc = "Projects", action = "<leader>p" },
						{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
					},
				},
				sections = {
					{ section = "header" },
					{ section = "keys", gap = 1, padding = 1 },
				},
			},
			dim = {
				animate = {
					enabled = false,
				},
			},
			indent = {
				enabled = true,

				animate = {
					style = "up",
					duration = {
						total = 15,
					},
				},
			},
			input = { enabled = true },
			picker = { enabled = false },
			notifier = { enabled = false },
			quickfile = { enabled = true },
			scope = { enabled = true },
			--scroll = { enabled = true },
			statuscolumn = { enabled = true },
			words = { enabled = true },
		},
		keys = {
			{
				"<leader>.",
				function()
					Snacks.scratch()
				end,
				desc = "Toggle Scratch Buffer",
			},
			{
				"<leader>S",
				function()
					Snacks.scratch.select()
				end,
				desc = "Select Scratch Buffer",
			},
			{
				"<leader>z",
				function()
					Snacks.zen({
						show = {
							tabline = true,
						},
					})
				end,
			},
		},
	},
	{
		"ahmedkhalf/project.nvim",
		config = function()
			require("project_nvim").setup({})
			require("telescope").load_extension("projects")
		end,
	},
}
