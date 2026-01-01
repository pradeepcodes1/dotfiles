return {
	{
		"shortcuts/no-neck-pain.nvim",
		version = "*",
		lazy = false,
		config = function()
			local log = require("core.logging")
			local nnp_width = 140
			-- Minimum width needed: main buffer + some space for side buffers
			-- If window is smaller than this, side buffers can't render properly
			-- Need extra space for side buffers: at least 10 cols each side + some padding
			local min_width_for_side_buffers = nnp_width + 40

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

			local function ensure_enabled()
				if is_window_too_small() then
					log.debug("no-neck-pain", "window too small, skipping enable", {
						columns = vim.o.columns,
						min_required = min_width_for_side_buffers,
					})
					return
				end
				local nnp = require("no-neck-pain")
				if not nnp.state or not nnp.state.enabled then
					log.debug("no-neck-pain", "enabling", { columns = vim.o.columns })
					-- Defer to let any pending window operations complete (e.g., yazi closing)
					vim.defer_fn(function()
						-- Re-check size in case window changed
						if not is_window_too_small() then
							local state = require("no-neck-pain").state
							if not state or not state.enabled then
								vim.cmd("NoNeckPain")
							end
						end
					end, 10)
				end
			end

			local function disable_if_enabled()
				local nnp = require("no-neck-pain")
				if nnp.state and nnp.state.enabled then
					log.debug("no-neck-pain", "disabling due to small window", {
						columns = vim.o.columns,
						min_required = min_width_for_side_buffers,
					})
					vim.cmd("NoNeckPain")
				end
			end

			-- Enable on startup
			vim.api.nvim_create_autocmd("VimEnter", {
				callback = function()
					log.debug("no-neck-pain", "VimEnter triggered")
					ensure_enabled()
				end,
			})

			-- Enable when switching tabs/buffers
			vim.api.nvim_create_autocmd("TabEnter", {
				callback = function()
					log.debug("no-neck-pain", "TabEnter triggered")
					ensure_enabled()
				end,
			})

			-- Handle window resize events
			vim.api.nvim_create_autocmd("VimResized", {
				callback = function()
					log.debug("no-neck-pain", "VimResized triggered", { columns = vim.o.columns })
					if is_window_too_small() then
						disable_if_enabled()
					else
						ensure_enabled()
					end
				end,
			})
		end,
	},
}
