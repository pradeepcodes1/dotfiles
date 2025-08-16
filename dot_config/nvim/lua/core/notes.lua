local function get_notes_root_dir()
	return vim.fn.stdpath("data") .. "/notes"
end

local function create_and_open_in_new_tab(file_path, content)
	-- Create parent directories if they don't exist
	local dir = vim.fs.dirname(file_path)
	if dir and vim.loop.fs_stat(dir) == nil then
		vim.fn.mkdir(dir, "p")
	end

	-- Open file and write content
	local file, err = io.open(file_path, "w")
	if not file then
		print("Error creating file:", err)
		return false
	end
	file:write(content)
	file:close()

	-- Open the file in a new tab
	vim.api.nvim_command("tabnew " .. file_path)

	return true
end

vim.keymap.set("n", "<leader>nn", function()
	-- Define the directory where notes are stored
	-- Create a unique filename, e.g., based on the current timestamp
	local filename = os.date("%Y-%m-%d-%H%M%S") .. ".md"
	local file_path = get_notes_root_dir() .. "/" .. filename

	-- Initial content for the new note (optional)
	local content = "# " .. os.date("%Y-%m-%d") .. "\n\n"

	create_and_open_in_new_tab(file_path, content)
end, { desc = "Create note and open" })

vim.keymap.set("n", "<leader>nf", function()
	-- Assumes your notes are in ~/.config/nvim/notes/
	require("telescope.builtin").find_files({ cwd = get_notes_root_dir() })
end, { desc = "Find notes" })

-- Autosave

local AutoSaveGroup = vim.api.nvim_create_augroup("AutoSaveScratch", { clear = true })

-- 3. Create the autocmd
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
	group = AutoSaveGroup,
	pattern = get_notes_root_dir() .. "/*", -- The pattern to match files in the directory
	desc = "Auto save for scratch files",
	-- Use ":update" which only writes if the buffer is modified
	command = "silent! update",
})

vim.o.updatetime = 500
