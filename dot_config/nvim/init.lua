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

require("lazy").setup({ import = "plugins" })

require("core.cmp")
require("core.notes")

-- Theme configuration from dotfiles env vars (set by ~/.config/colors/*.sh)
local nvim_colorscheme = os.getenv("_DOTFILES_NVIM_COLORSCHEME") or "kanagawa-dragon"
local nvim_background = os.getenv("_DOTFILES_NVIM_BACKGROUND") -- nil, "dark", or "light"
local theme_transparent = os.getenv("_DOTFILES_THEME_TRANSPARENT") == "1"

-- Only enable transparent background if theme metadata says it's ok
if theme_transparent then
	vim.api.nvim_create_augroup("TransparentBG", { clear = true })
	vim.api.nvim_create_autocmd("ColorScheme", {
		pattern = "*",
		group = "TransparentBG",
		callback = function()
			vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
			vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })
			vim.api.nvim_set_hl(0, "LineNr", { bg = "NONE" })
			vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
			vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "NONE" })
		end,
	})
end

-- When Neovim starts with a single argument that is a directory,
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

local readonly_libs = vim.api.nvim_create_augroup("readonly_libs", { clear = true })

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	group = readonly_libs,
	pattern = {
		"*/node_modules/*",
		"*/site-packages/*",
		"*/vendor/*",
		"*/homebrew/Cellar/*",
		"*/mise/installs/*",
		vim.fn.expand("~") .. "/go/*",
	},
	callback = function()
		vim.opt_local.modifiable = false
		vim.opt_local.readonly = true
	end,
})

-- Apply theme from env vars
if nvim_background then
	vim.o.background = nvim_background
end
vim.cmd.colorscheme(nvim_colorscheme)

-- Suppress specific deprecation warnings
-- TODO: Remove once plugins are updated
local original_deprecate = vim.deprecate
vim.deprecate = function(name, alternative, version, plugin, backtrace)
	if
		name == "vim.lsp.buf_get_clients()"
		or name == "client.is_stopped"
		or name == "vim.tbl_flatten"
		or name == "vim.tbl_islist"
		or name == "vim.validate"
	then
		return
	end
	original_deprecate(name, alternative, version, plugin, backtrace)
end
