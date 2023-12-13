local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Increment/decrement
keymap.set("n", "+", "<C-a>", opts)
keymap.set("n", "-", "<C-x>", opts)

keymap.set("n", "<C-e>", "5<C-e>", opts)
keymap.set("n", "<C-y>", "5<C-y>", opts)

keymap.set("v", "<tab>", ">gv")
keymap.set("v", "<s-tab>", "<gv")

keymap.set("n", "`", "'", opts)
keymap.set("n", "'", "`", opts)

-- New tab (prefer using akinsho/bufferline.nvim)
-- keymap.set("n", "<C-n>", ":tabnext<Return>", opts)
-- keymap.set("n", "<C-p>", ":tabprev<Return>", opts)

-- Move window
keymap.set("n", "<C-h>", "<C-w>h")
keymap.set("n", "<C-j>", "<C-w>j")
keymap.set("n", "<C-k>", "<C-w>k")
keymap.set("n", "<C-l>", "<C-w>l")

-- Resize window
keymap.set("n", "<C-w><C-h>", "<C-w>10<")
keymap.set("n", "<C-w><C-l>", "<C-w>10>")
keymap.set("n", "<C-w><C-k>", "<C-w>5-")
keymap.set("n", "<C-w><C-j>", "<C-w>5+")

keymap.set("n", "<leader>n", ":Neotree toggle<Return>")

-- Depends on: smjonas/inc-rename.nvim
keymap.set("n", "<leader>rn", ":IncRename ")
