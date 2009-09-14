set backspace=indent,eol,start
colorscheme xoria256
"set background=dark

set nohlsearch
set incsearch

set foldenable
set foldmethod=syntax

set expandtab
set shiftwidth=4
set softtabstop=4
set smarttab

set autoindent
set smartindent
" don't always put # against the margin (python comment)
inoremap # X#

set showcmd
set formatoptions=tcroql
" set formatoptions += an "breaks coding
syn sync fromstart

set ignorecase
set smartcase

set wildmenu
set cursorline
set modeline

set encoding=utf-8

" I find rulerformat more compact than statusline
set ruler
set rulerformat=%40(%=%t%m%r%y\ \ %l,%c\ \ %P%)
" set laststatus=2
" set statusline=
" set statusline+=%-3.3n\
" set statusline+=%f\
" set statusline+=%h%m%r%w
" set statusline+=\[%{strlen(&ft)?&ft:'none'}]
" set statusline+=%=
" set statusline+=0x%-8B
" set statusline+=%-14(%l,%c%V%)
" set statusline+=%<%P

filetype on
filetype plugin on
filetype indent on

"set shellslash
set grepprg=grep\ -nH\ $*

set mouse=
set showbreak=->

set wildignore=*.o,*.obj,*.bak

au BufNewFile,BufRead *.frag,*.vert,*.fp,*.vp,*.glsl setf glsl
au BufNewFile,BufRead *.draft setf draft
autocmd BufNewFile,BufRead *.as set filetype=actionscript

nnoremap <space> za
imap <c-space> <c-x><c-o>
nnoremap Q gqap

map <C-Left> <C-W>1<
map <C-Right> <C-W>1>
map <C-Up> <C-W>1-
map <C-Down> <C-W>1+
nmap <C-n> :tabnext<CR>
nmap <C-p> :tabprevious<CR>

"setlocal spell spelllang=en
