-- core/options.lua
local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.termguicolors = true
opt.clipboard = "unnamedplus"
opt.updatetime = 300
opt.splitright = true
opt.splitbelow = true
opt.termguicolors = true
opt.ignorecase = true
opt.cursorline = true
opt.wrap = false

-- Smooth scrolling options
opt.scrolloff = 8        -- Keep 8 lines visible above/below cursor
opt.sidescrolloff = 8    -- Keep 8 columns visible left/right of cursor
opt.smoothscroll = true  -- Enable smooth scrolling (Neovim 0.10+)

-- Disable terminal title to prevent conflicts with tmux status bar colors
opt.title = false
opt.titlestring = ""
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		require("conform").format({ bufnr = args.buf })
	end,
})
vim.o.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
	pattern = "*",
	command = "if mode() != 'c' | checktime | endif",
})

-- Restore terminal cursor to underscore on exit (prevents vim block cursor persisting)
vim.api.nvim_create_autocmd("VimLeave", {
	callback = function()
		vim.opt.guicursor = "a:hor20"
		io.write("\027[4 q")
	end,
})
