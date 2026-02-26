local map = vim.keymap.set
vim.g.mapleader = " "

-- basics
map("i", "jk", "<Esc>", { desc = "Exit insert mode with jk" })
map("v", "jk", "<Esc>", { desc = "Exit visual mode with jk" })
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
map("n", "<leader>/", ":Telescope current_buffer_fuzzy_find<CR>", { desc = "Smart buffer search (symbols/fuzzy)" })
map("n", "<leader>fs", function()
	local bufname = vim.api.nvim_buf_get_name(0)
	local is_virtual = bufname:match("^%w+://") and not bufname:match("^file://")
	require("telescope.builtin").lsp_document_symbols({
		previewer = not is_virtual,
	})
end, { desc = "Find symbols in file" })
map("n", "<leader>fw", ":Telescope lsp_workspace_symbols<CR>", { desc = "Find symbols in workspace" })
map("n", "<leader>fr", ":Telescope oldfiles<CR>", { desc = "Recent files" })
map("n", "<leader>`", ":Telescope buffers<CR>", { desc = "Search open buffers" })
-- LSP (gd, rename, code_action are in lsp/common.lua on_attach)
map("n", "<leader>lc", "<Cmd>cclose<CR>", { desc = "Clear quickfix" })
map("n", "?", vim.diagnostic.open_float, { desc = "Open diagnostic float" })
map("n", "]d", function()
	vim.diagnostic.jump({ count = 1 })
end, { desc = "Next diagnostic" })
map("n", "[d", function()
	vim.diagnostic.jump({ count = -1 })
end, { desc = "Previous diagnostic" })
map("n", "<leader>lh", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })
map("n", "<leader>ud", function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostics" })

-- Show dashboard and restore tabline when leaving it
function _G._show_dashboard()
	if Snacks and Snacks.dashboard then
		local saved_tabline = vim.o.showtabline
		Snacks.dashboard()
		vim.api.nvim_create_autocmd("BufEnter", {
			once = true,
			callback = function()
				if vim.bo.filetype ~= "snacks_dashboard" then
					vim.o.showtabline = saved_tabline
				end
			end,
		})
	end
end

-- Split navigation
map("n", "<leader><Left>", "<C-w>h", { desc = "Move to left split" })
map("n", "<leader><Right>", "<C-w>l", { desc = "Move to right split" })
map("n", "<leader><Up>", "<C-w>k", { desc = "Move to split above" })
map("n", "<leader><Down>", "<C-w>j", { desc = "Move to split below" })

-- BarBar keymaps
local opts = { noremap = true, silent = true }
map("n", "bk", "<Cmd>BufferPick<CR>", opts)
map("n", "<leader>q", function()
	vim.cmd("BufferClose")
	vim.schedule(function()
		local remaining = vim.tbl_filter(function(b)
			return vim.api.nvim_buf_is_valid(b) and vim.bo[b].buflisted and vim.api.nvim_buf_get_name(b) ~= ""
		end, vim.api.nvim_list_bufs())
		if #remaining == 0 then
			_show_dashboard()
		end
	end)
end, { noremap = true, silent = true, desc = "Close buffer (dashboard if last)" })

-- Project management
map("n", "<leader>p", function()
	require("telescope").extensions.projects.projects({})
end, { desc = "Projects" })

-- Splits
map("n", "<leader>|", "<cmd>vsplit<CR>", { desc = "Split vertical" })
map("n", "<leader>\\", "<cmd>split<CR>", { desc = "Split horizontal" })
map("n", "<leader>x", "<C-w>c", { desc = "Close split" })

-- Stop search highlighting when presesing escape
map("n", "<Esc><Esc>", ":nohlsearch<CR><Esc>", { desc = "Clear search highlighting" })

map("i", "<A-Left>", "<C-o>b", opts) -- back one word
map("i", "<A-Right>", "<C-o>w", opts) -- forward one word

for i = 1, 9 do
	map("n", "<leader>" .. i, "<Cmd>BufferGoto " .. i .. "<CR>", opts)
end
map("n", "<leader>0", "<Cmd>BufferPin<CR>", opts)

local move_keys = { "!", "@", "#", "$", "%", "^", "&", "*", "(" }
for i, key in ipairs(move_keys) do
	map("n", "<leader>" .. key, "<Cmd>BufferMove " .. i .. "<CR>", opts)
end

local function is_diffview_open()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
		if ft == "DiffviewFiles" or ft == "DiffviewFileHistory" then
			return true
		end
	end
	return false
end

local function diffview_review()
	vim.cmd("DiffviewOpen")
end

local function diffview_file()
	vim.cmd("DiffviewOpen -- %")
	vim.cmd("DiffviewToggleFiles")
end

local function diffview_close()
	if is_diffview_open() then
		vim.cmd("DiffviewClose")
	end
end

map("n", "<leader>gr", diffview_review, { desc = "Diffview review" })
map("n", "<leader>df", diffview_file, { desc = "Diffview current file" })
map("n", "<leader>gc", diffview_close, { desc = "Diffview close" })

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
