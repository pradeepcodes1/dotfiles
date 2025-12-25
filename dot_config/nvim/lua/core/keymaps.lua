local map = vim.keymap.set
vim.g.mapleader = " "

-- basics
map("i", "jk", "<Esc>", { desc = "Exit insert mode with jk" })
map("v", "jk", "<Esc>", { desc = "Exit visual mode with jk" })
map("n", "<ScrollWheelRight>", "<Nop>")

-- Telescope
-- Note: <leader>e is mapped to Yazi in plugins/yazi.lua
map("n", "<leader>ff", function()
	require("telescope.builtin").find_files({
		previewer = false,
		layout_config = {
			width = 0.45,
		},
	})
end, { desc = "Find Files (no preview)" })
map("n", "<leader>fg", ":Telescope live_grep<CR>", { desc = "Grep" })
--map("n", "<leader>/", "/", { desc = "Remapping normal text search" })
map("n", "<leader>/", ":Telescope current_buffer_fuzzy_find<CR>", { desc = "Smart buffer search (symbols/fuzzy)" })
map("n", "<leader>fs", ":Telescope lsp_document_symbols<CR>", { desc = "Find symbols in file" })
map("n", "<leader>fw", ":Telescope lsp_workspace_symbols<CR>", { desc = "Find symbols in workspace" })
map("n", "<leader>fr", ":Telescope oldfiles<CR>", { desc = "Recent files" })
-- LSP
map("n", "<leader>lr", vim.lsp.buf.rename, { desc = "LSP Rename" })
map("n", "<leader>la", vim.lsp.buf.code_action, { desc = "Code Action" })
map("n", "<leader>lc", "<Cmd>cclose<CR>", { desc = "Clear quickfix" })
map("n", "gd", vim.lsp.buf.definition, { desc = "Goto Definition" })
map("n", "?", vim.diagnostic.open_float, { desc = "Open diagnostic float" })

-- BarBar keymaps
local opts = { noremap = true, silent = true }
map("n", "bk", "<Cmd>BufferPick<CR>", opts)
map("n", "<leader>q", "<Cmd>BufferClose<CR>", opts)

-- Project management
map("n", "<leader>p", function()
	require("telescope").extensions.projects.projects({})
end, { desc = "Projects" })

-- Stop search highlighting when presesing escape
map("n", "<Esc><Esc>", ":nohlsearch<CR><Esc>", { desc = "Clear search highlighting" })

map("i", "<A-Left>", "<C-o>b", opts) -- back one word
map("i", "<A-Right>", "<C-o>w", opts) -- forward one word

map("n", "<leader>1", "<Cmd>BufferGoto 1<CR>", opts)
map("n", "<leader>2", "<Cmd>BufferGoto 2<CR>", opts)
map("n", "<leader>3", "<Cmd>BufferGoto 3<CR>", opts)
map("n", "<leader>4", "<Cmd>BufferGoto 4<CR>", opts)
map("n", "<leader>5", "<Cmd>BufferGoto 5<CR>", opts)
map("n", "<leader>6", "<Cmd>BufferGoto 6<CR>", opts)
map("n", "<leader>7", "<Cmd>BufferGoto 7<CR>", opts)
map("n", "<leader>8", "<Cmd>BufferGoto 8<CR>", opts)
map("n", "<leader>9", "<Cmd>BufferGoto 9<CR>", opts)
map("n", "<leader>0", "<Cmd>BufferLast<CR>", opts)

map("n", "<leader>!", "<Cmd>BufferMove 1<CR>", opts)
map("n", "<leader>@", "<Cmd>BufferMove 2<CR>", opts)
map("n", "<leader>#", "<Cmd>BufferMove 3<CR>", opts)
map("n", "<leader>$", "<Cmd>BufferMove 4<CR>", opts)
map("n", "<leader>%", "<Cmd>BufferMove 5<CR>", opts)
map("n", "<leader>^", "<Cmd>BufferMove 6<CR>", opts)
map("n", "<leader>&", "<Cmd>BufferMove 7<CR>", opts)
map("n", "<leader>*", "<Cmd>BufferMove 8<CR>", opts)
map("n", "<leader>(", "<Cmd>BufferMove 9<CR>", opts)

local function is_diffview_open()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		local ft = vim.api.nvim_buf_get_option(buf, "filetype")
		if ft == "DiffviewFiles" or ft == "DiffviewFileHistory" then
			return true
		end
	end
	return false
end

_G.diffview_review = function()
	vim.cmd("DiffviewOpen")
end

_G.diffview_file = function()
	vim.cmd("DiffviewOpen -- %")
	vim.cmd("DiffviewToggleFiles")
end

_G.diffview_close = function()
	if is_diffview_open() then
		vim.cmd("DiffviewClose")
	end
end

map("n", "<leader>gr", "<cmd>lua diffview_review()<CR>")
map("n", "<leader>gd", "<cmd>lua diffview_file()<CR>")
map("n", "<leader>gc", "<cmd>lua diffview_close()<CR>")

map("n", "<leader>Q", "<cmd>qa<CR>", {
	noremap = true,
	silent = true,
	desc = "Quit Neovim",
})

-- Yazi file manager
map({ "n", "v" }, "<leader>-", "<cmd>Yazi<cr>", { desc = "Open yazi at current file" })
map("n", "<leader>e", "<cmd>Yazi cwd<cr>", { desc = "Open yazi in cwd" })
map("n", "<c-up>", "<cmd>Yazi toggle<cr>", { desc = "Resume last yazi session" })

-- Todo-comments
map("n", "<leader>ft", "<cmd>TodoTelescope<CR>", { desc = "Find TODOs" })
map("n", "]t", function()
	require("todo-comments").jump_next()
end, { desc = "Next TODO" })
map("n", "[t", function()
	require("todo-comments").jump_prev()
end, { desc = "Previous TODO" })

-- Neoscroll (smooth scrolling)
local neoscroll_ok, neoscroll = pcall(require, "neoscroll")
if neoscroll_ok then
	local scroll_modes = { "n", "v", "x" }
	map(scroll_modes, "<ScrollWheelUp>", function()
		neoscroll.scroll(-5, { move_cursor = true, duration = 100 })
	end)
	map(scroll_modes, "<ScrollWheelDown>", function()
		neoscroll.scroll(5, { move_cursor = true, duration = 100 })
	end)
	map(scroll_modes, "<C-u>", function()
		neoscroll.ctrl_u({ duration = 150 })
	end)
	map(scroll_modes, "<C-d>", function()
		neoscroll.ctrl_d({ duration = 150 })
	end)
	map(scroll_modes, "<C-b>", function()
		neoscroll.ctrl_b({ duration = 250 })
	end)
	map(scroll_modes, "<C-f>", function()
		neoscroll.ctrl_f({ duration = 250 })
	end)
	map(scroll_modes, "<C-y>", function()
		neoscroll.scroll(-0.1, { move_cursor = false, duration = 50 })
	end)
	map(scroll_modes, "<C-e>", function()
		neoscroll.scroll(0.1, { move_cursor = false, duration = 50 })
	end)
	map(scroll_modes, "zt", function()
		neoscroll.zt({ half_win_duration = 100 })
	end)
	map(scroll_modes, "zz", function()
		neoscroll.zz({ half_win_duration = 100 })
	end)
	map(scroll_modes, "zb", function()
		neoscroll.zb({ half_win_duration = 100 })
	end)
end
