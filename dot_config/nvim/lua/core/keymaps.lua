-- core/keymaps.lua
local map = vim.keymap.set
vim.g.mapleader = " "
map("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Explorer" })
map("n", "<leader>ff", ":Telescope find_files<CR>", { desc = "Find Files" })
map("n", "<leader>fg", ":Telescope live_grep<CR>", { desc = "Grep" })
map("n", "<leader>fb", ":Telescope current_buffer_fuzzy_find<CR>", { desc = "Grep current buffer" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP Rename" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })

vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Goto Definition" })

-- BarBar keymaps
local opts = { noremap = true, silent = true }
map("n", "b<Left>", "<Cmd>BufferPrevious<CR>", opts)
map("n", "b<Right>", "<Cmd>BufferNext<CR>", opts)
map("n", "bk", "<Cmd>BufferPick<CR>", opts)
map("n", "bg1", "<Cmd>BufferGoto 1<CR>", opts)
map("n", "bg2", "<Cmd>BufferGoto 2<CR>", opts)
map("n", "bg3", "<Cmd>BufferGoto 3<CR>", opts)
map("n", "bg4", "<Cmd>BufferGoto 4<CR>", opts)
map("n", "bg5", "<Cmd>BufferGoto 5<CR>", opts)
map("n", "bg6", "<Cmd>BufferGoto 6<CR>", opts)
map("n", "bg7", "<Cmd>BufferGoto 7<CR>", opts)
map("n", "bg8", "<Cmd>BufferGoto 8<CR>", opts)
map("n", "bg9", "<Cmd>BufferGoto 9<CR>", opts)
map("n", "bg0", "<Cmd>BufferLast<CR>", opts)

-- Terminal keymaps
map("n", "<leader>t", "<Cmd>ToggleTerm<CR>", opts)
map("n", "<leader>th", "<Cmd>ToggleTerm direction=horizontal<CR>", opts)
map("n", "<leader>tv", "<Cmd>ToggleTerm direction=vertical<CR>", opts)
