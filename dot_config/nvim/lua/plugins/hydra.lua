return {
	"nvimtools/hydra.nvim",
	config = function()
		local Hydra = require("hydra")

		Hydra({
			name = "Buffer",
			mode = "n",
			body = "<leader>b",
			heads = {
				{ "1", "<Cmd>BufferGoto 1<CR>", { desc = "buf 1" } },
				{ "2", "<Cmd>BufferGoto 2<CR>", { desc = "buf 2" } },
				{ "3", "<Cmd>BufferGoto 3<CR>", { desc = "buf 3" } },
				{ "4", "<Cmd>BufferGoto 4<CR>", { desc = "buf 4" } },
				{ "5", "<Cmd>BufferGoto 5<CR>", { desc = "buf 5" } },
				{ "6", "<Cmd>BufferGoto 6<CR>", { desc = "buf 6" } },
				{ "7", "<Cmd>BufferGoto 7<CR>", { desc = "buf 7" } },
				{ "8", "<Cmd>BufferGoto 8<CR>", { desc = "buf 8" } },
				{ "9", "<Cmd>BufferGoto 9<CR>", { desc = "buf 9" } },
				{ "0", "<Cmd>BufferLast<CR>", { desc = "last" } },
				{ "h", "<Cmd>BufferPrevious<CR>", { desc = "prev" } },
				{ "l", "<Cmd>BufferNext<CR>", { desc = "next" } },
				{ "q", "<Cmd>BufferClose<CR>", { desc = "close" } },
				{ "<Esc>", nil, { exit = true, desc = "exit" } },
			},
			config = {
				hint = {
					type = "window",
					position = "bottom",
				},
				invoke_on_body = true,
				timeout = 3000, -- auto-exit after 3s of inactivity
			},
		})
	end,
}
