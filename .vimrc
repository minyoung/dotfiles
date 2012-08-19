set nocompatible

call pathogen#infect()

let mapleader=","

inoremap jj <esc>

nnoremap / /\v
vnoremap / /\v

" pretty colors and looks
" try my preferred colorscheme first (xoria256),
" if that fails, then use a default colorscheme that *should* be present
if &t_Co == 256 || has("gui_running")
    try
        colorscheme xoria256
    catch /.*/
        colorscheme mustang
    endtry
else
    colorscheme desert
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
set infercase

" folding
set foldenable

" just set the default foldmarker to {,}, which is the most common
" filetypes.vimrc will set foldmethod as appropriate
set foldmarker={,}
" shortcut key to help with manual folding
vmap <leader>f :fold<CR>

" Don't screw up folds when inserting text that might affect them, until
" leaving insert mode. Foldmethod is local to the window.
autocmd InsertEnter * let w:last_fdm=&foldmethod | setlocal foldmethod=manual
autocmd InsertLeave * let &l:foldmethod=w:last_fdm

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
set wildmode=list:longest
set wildignore=*.o,*.obj,*.bak,*.class,*.pyc,*.swp

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

" couldn't be bothered with the extra backup and swap files
set nobackup
set noswapfile

" toggle fold with space
nnoremap <space> za

" move between tabs easier
nmap <C-n> :tabnext<CR>
nmap <C-p> :tabprevious<CR>

" format paragraph
nnoremap Q gqap

" resize windows
map <C-w><C-h> <C-w>10<
map <C-w><C-l> <C-w>10>
map <C-w><C-k> <C-w>5-
map <C-w><C-j> <C-w>5+

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

" tab and shift-tab to indent and unindent
vmap <tab> >gv
vmap <s-tab> <gv

" only have cursorline in the current window
autocmd WinLeave * set nocursorline
autocmd WinEnter * set cursorline

" random
set hidden
set winaltkeys=no

" mksession
set sessionoptions=buffers,curdir,folds,tabpages,winsize

if exists("+undofile")
    " persistent undo
    set undodir=~/.vim/undodir
    set undofile
endif

" when editing a file, always jump to the last cursor position
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

" Function to set the screen title
function! SetTitle()
    " get current filename, replacing ' with \'
    let l:filename = substitute(expand('%:~:.'), "'", '\\''', '')
    let l:title = 'vim - ' . l:filename
    " let l:truncTitle = strpart(l:title, 0, 15)
    silent exe "!set_title.sh '" . l:title . "'"
endfunction

" Run it every time we change buffers
autocmd BufEnter * call SetTitle()


" nerd_commenter
map <leader><leader> ,c<space>
let NERDSpaceDelims=1

" nerd_tree
nmap <leader>n :NERDTreeToggle<CR>
nmap <leader>f :NERDTreeFind<CR>
let NERDTreeShowBookmarks=1
let NERDTreeBookmarksFile=expand("$HOME/.vim/NERDTreeBookmarks")
let NERDTreeConfirmDeleteBookmark=0

" CommandT
nmap <leader>m :CommandTBuffer<CR>
let g:CommandTMaxHeight=20

" SuperTab
let g:SuperTabDefaultCompletionType='<c-n>'
let g:SuperTabLongestEnhanced=1

source $HOME/.vim/filetypes.vimrc
if filereadable(expand("$HOME/.vim/local.vimrc"))
    source $HOME/.vim/local.vimrc
end
