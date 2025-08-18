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

vim.cmd.colorscheme("kanagawa-dragon") -- set colorscheme
