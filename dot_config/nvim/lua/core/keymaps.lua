local map = vim.keymap.set
vim.g.mapleader = " "

-- basics
map("i", "jk", "<Esc>", { desc = "Exit insert mode with jk" })
map("v", "jk", "<Esc>", { desc = "Exit visual mode with jk" })

-- Telescope
map("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Explorer" })
map("n", "<leader>ff", function()
	require("telescope.builtin").find_files({
		previewer = false,
		layout_config = {
			width = 0.45,
		},
	})
end, { desc = "Find Files (no preview)" })
map("n", "<leader>fg", ":Telescope live_grep<CR>", { desc = "Grep" })
map("n", "<leader>/", "/", { desc = "Remapping normal text search" })
map("n", "/", ":Telescope current_buffer_fuzzy_find<CR>", { desc = "Smart buffer search (symbols/fuzzy)" })
map("n", "<leader>fs", ":Telescope lsp_document_symbols<CR>", { desc = "Find symbols in file" })
map("n", "<leader>fw", ":Telescope lsp_workspace_symbols<CR>", { desc = "Find symbols in workspace" })

-- LSP
map("n", "<leader>lr", vim.lsp.buf.rename, { desc = "LSP Rename" })
map("n", "<leader>la", vim.lsp.buf.code_action, { desc = "Code Action" })
map("n", "gd", vim.lsp.buf.definition, { desc = "Goto Definition" })

-- BarBar keymaps
local opts = { noremap = true, silent = true }
map("n", "b<Left>", "<Cmd>BufferPrevious<CR>", opts)
map("n", "b<Right>", "<Cmd>BufferNext<CR>", opts)
map("n", "bk", "<Cmd>BufferPick<CR>", opts)

-- Terminal keymaps
map("n", "<leader>t", "<Cmd>ToggleTerm<CR>", opts)
map("n", "<leader>th", "<Cmd>ToggleTerm direction=horizontal<CR>", opts)
map("n", "<leader>tv", "<Cmd>ToggleTerm direction=vertical<CR>", opts)

-- Project management
--map("n", "<leader>p", ":Telescope projects<CR>", { desc = "Projects" })
map("n", "<leader>p", function()
	require("telescope").extensions.projects.projects({})
end, { desc = "Projects" })
