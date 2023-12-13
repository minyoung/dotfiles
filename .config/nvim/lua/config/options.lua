vim.g.mapleader = ","

vim.scriptencoding = "utf-8"
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

vim.opt.title = true
vim.opt.cursorline = true

vim.opt.backup = false
vim.opt.swapfile = false

vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.breakindent = true
vim.opt.shiftround = true

vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.smarttab = true

vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true -- Case insensitive searching UNLESS /C or capital in search
vim.opt.smartcase = true

vim.opt.relativenumber = true

vim.opt.showcmd = true
vim.opt.inccommand = "split"
vim.opt.wildmode = "longest:full"
vim.opt.wildignore:append({ "*/node_modules/*" })
vim.opt.completeopt = "longest,menu,preview"

vim.opt.scrolloff = 10

vim.opt.backspace = { "start", "eol", "indent" }

vim.opt.errorbells = false
vim.opt.visualbell = false

vim.opt.list = true
vim.opt.listchars = "tab:»·,trail:·"
vim.opt.showbreak = "≈»"

vim.opt.colorcolumn = "121"

vim.opt.mouse = ""
