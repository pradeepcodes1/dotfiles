-- init.lua
require("core.options")
require("core.keymaps")

-- Bootstrap lazy.nvim if missing
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins") -- load plugin specs
require("core.cmp")
require("core.notes")
vim.api.nvim_create_augroup("TransparentBG", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	group = "TransparentBG",
	callback = function()
		-- Set the main background to transparent
		vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })

		-- Set backgrounds for non-current windows, line numbers, etc., to transparent
		vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })
		vim.api.nvim_set_hl(0, "LineNr", { bg = "NONE" })
		vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
		vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "NONE" })
	end,
})

-- Whe n Neovim starts with a single argument that is a directory,
vim.api.nvim_create_autocmd("VimEnter", {
	desc = "Change CWD to dir if it's the only argument",
	pattern = "*",
	once = true, -- Run only once on startup
	callback = function()
		-- Get the arguments passed to nvim
		local args = vim.v.argv
		-- Check if there is exactly one argument and it's a directory
		if #args == 1 and vim.fn.isdirectory(args[1]) == 1 then
			-- Change Neovim's current working directory
			vim.cmd.cd(args[1])
			-- Open the file explorer (netrw) in the new CWD
			vim.cmd.edit(".")
		end
	end,
})

vim.cmd.colorscheme("everforest") -- set colorscheme
