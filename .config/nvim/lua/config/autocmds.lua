-- Turn off paste mode when leaving insert
vim.api.nvim_create_autocmd("InsertLeave", {
	pattern = "*",
	command = "set nopaste",
})

-- Only have cursorline in the current window
vim.api.nvim_create_autocmd("WinLeave", {
	pattern = "*",
	command = "set nocursorline",
})
vim.api.nvim_create_autocmd("WinEnter", {
	pattern = "*",
	command = "set cursorline",
})
