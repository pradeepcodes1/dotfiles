return {
	{
		"shortcuts/no-neck-pain.nvim",
		version = "*",
		lazy = false,
		config = function()
			local log = require("core.logging")
			local nnp_width = 140
			local min_width_for_side_buffers = nnp_width + 40

			-- Track whether a sidebar suppressed no-neck-pain
			local nnp_suppressed = false

			local function is_window_too_small()
				return vim.o.columns < min_width_for_side_buffers
			end

			require("no-neck-pain").setup({
				width = nnp_width,
				autocmds = {
					enableOnVimEnter = false,
					enableOnTabEnter = false,
					skipEnteringNoNeckPainBuffer = true,
				},
			})

			local function is_enabled()
				local nnp = require("no-neck-pain")
				return nnp.state and nnp.state.enabled
			end

			local function enable()
				if is_window_too_small() or is_enabled() then
					return
				end
				log.debug("no-neck-pain", "enabling", { columns = vim.o.columns })
				vim.defer_fn(function()
					if not is_window_too_small() and not is_enabled() then
						vim.cmd("NoNeckPain")
					end
				end, 10)
			end

			local function disable()
				if is_enabled() then
					log.debug("no-neck-pain", "disabling", { columns = vim.o.columns })
					vim.cmd("NoNeckPain")
				end
			end

			-- Left/right sidebar filetypes that conflict with centering
			local sidebar_fts = {
				aerial = true,
				["neotest-summary"] = true,
				dapui_scopes = true,
				dapui_breakpoints = true,
				dapui_stacks = true,
				dapui_watches = true,
			}

			local function has_sidebar_open()
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					local buf = vim.api.nvim_win_get_buf(win)
					local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
					if sidebar_fts[ft] then
						return true
					end
				end
				return false
			end

			-- React to windows opening/closing
			vim.api.nvim_create_autocmd({ "BufWinEnter", "WinClosed" }, {
				callback = function()
					vim.schedule(function()
						if has_sidebar_open() then
							if not nnp_suppressed then
								nnp_suppressed = true
								disable()
							end
						else
							if nnp_suppressed then
								nnp_suppressed = false
								enable()
							end
						end
					end)
				end,
			})

			-- Enable on startup
			vim.api.nvim_create_autocmd("VimEnter", {
				callback = function()
					log.debug("no-neck-pain", "VimEnter triggered")
					enable()
				end,
			})

			-- Enable when switching tabs
			vim.api.nvim_create_autocmd("TabEnter", {
				callback = function()
					if not nnp_suppressed then
						enable()
					end
				end,
			})

			-- Handle window resize
			vim.api.nvim_create_autocmd("VimResized", {
				callback = function()
					if nnp_suppressed then
						return
					end
					if is_window_too_small() then
						disable()
					else
						enable()
					end
				end,
			})
		end,
	},
}
