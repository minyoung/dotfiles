set nocompatible

" pretty colors and looks
if &t_Co == 256
    colorscheme xoria256
else
    set background=dark
endif
syntax on
syn sync fromstart
set cursorline

" enable filetype detection and stuff
filetype on
filetype plugin on
filetype indent on
set modeline

" default encoding
set encoding=utf-8
set fileencoding=utf-8

" backspace over stuff
set backspace=indent,eol,start

" searching, incsearch with hlsearch is annoying
set nohlsearch
set incsearch

" useful for searching
set ignorecase
set smartcase

" folding
set foldenable
set foldmarker={,}
set foldmethod=marker
" set foldmethod=syntax
" set foldmethod=indent

" tab stuff
set expandtab
set shiftwidth=4
set softtabstop=4
set smarttab

" indentation
set autoindent
set smartindent
set shiftround
" don't always put # against the margin (python comment)
inoremap # X#

set formatoptions=tcroql
" set formatoptions+=an "breaks coding

" command stuff
set showcmd
set wildmenu
" set wildmode=list:longest
set wildignore=*.o,*.obj,*.bak

" make the clipboard the default register to use
set clipboard=unnamed,exclude:cons\|linux

" don't redraw during macros
set lazyredraw

" main thing is adding longest
set completeopt=longest,menu,preview

" don't use the mouse, let the terminal handle the mouse stuff
set mouse=

" keep context
set scrolloff=5

" don't like noise
set noerrorbells
set novisualbell
set t_vb=

" show line breaks
set showbreak=≈»

" see some unprintable character
set list
set listchars=tab:»·,trail:·

" I find rulerformat more compact than statusline
set ruler
set rulerformat=%40(%=%t%m%r%y\ \ %l,%c\ \ %p%)
" set ruler to 40 characters
" right align
" file title
" modified?
" readonly?
" filetype
" space space
" line number, column number
" space space
" percentage through file

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

" setlocal spell spelllang=en

" toggle fold with space
nnoremap <space> za

" move between tabs easier
nmap <C-n> :tabnext<CR>
nmap <C-p> :tabprevious<CR>

" format paragraph
nnoremap Q gqap

" resize windows
map <C-Left> <C-w>1<
map <C-Right> <C-w>1>
map <C-Up> <C-w>1-
map <C-Down> <C-w>1+

" jump around windows slightly easier
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-h> <C-w>h
map <C-l> <C-w>l

" useful remappings
noremap 0 ^
noremap ^ 0
noremap ` '
noremap ' `

" easier increment and decrement
nnoremap + <C-a>
nnoremap - <C-x>

" make Y work like C and D
nnoremap Y y$

" more informative <C-g>
nnoremap <C-g> 2<C-g>

" some file stuff
autocmd BufNewFile,BufRead *.frag,*.vert,*.fp,*.vp,*.glsl set filetype glsl
autocmd BufNewFile,BufRead *.draft set filetype draft
autocmd BufNewFile,BufRead *.as set filetype=actionscript

" when editing a file, always jump to the last cursor position
:au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

