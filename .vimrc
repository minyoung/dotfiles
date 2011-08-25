set nocompatible

let mapleader=","

call pathogen#helptags()
call pathogen#runtime_append_all_bundles()

map <leader><leader> ,c<space>
let NERDSpaceDelims=1

nmap <leader>n :NERDTreeToggle<CR>
nmap <leader>m :BufExplorer<CR>

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

" folding
set foldenable
" see near end of file for more folding stuff

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

" move between buffers easier
nmap <A-n> :bnext<CR>
nmap <A-p> :bprevious<CR>

" format paragraph
nnoremap Q gqap

" resize windows
map <C-w><C-h> <C-w>10<
map <C-w><C-l> <C-w>10>
map <C-w><C-k> <C-w>5-
map <C-w><C-j> <C-w>5+
" screen seems to cause this to break :/
" map <C-Left> <C-w>1<
" map <C-Right> <C-w>1>
" map <C-Up> <C-w>1-
" map <C-Down> <C-w>1+

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

" only have cursorline in the current window
autocmd WinLeave * set nocursorline
autocmd WinEnter * set cursorline

" some file type detection
autocmd BufNewFile,BufRead *.frag,*.vert,*.fp,*.vp,*.glsl,*.fsh,*.vsh set filetype=glsl
autocmd BufNewFile,BufRead *.as set filetype=actionscript
autocmd BufNewFile,BufRead *.mxml set filetype=mxml
autocmd BufNewFile,BufRead *.tex set filetype=tex
autocmd BufNewFile,BufRead *.mako set filetype=mako
autocmd BufNewFile,BufRead *.thrift set filetype=thrift

" just let the default foldmarker to {,}, which is the most common
" and do not set foldmethod automatically
set foldmarker={,}
" set foldmethod=marker
autocmd FileType actionscript set foldmethod=marker
autocmd FileType c set foldmethod=syntax
autocmd FileType cpp set foldmethod=syntax
autocmd FileType cs set foldmethod=syntax
autocmd FileType css set foldmethod=marker
autocmd FileType html set foldmethod=indent
autocmd FileType java set foldmethod=marker
autocmd FileType javascript set foldmethod=marker
autocmd FileType objc set foldmethod=marker
autocmd FileType php set foldmethod=marker
autocmd FileType python set foldmethod=indent
autocmd FileType ruby set foldmethod=syntax
autocmd FileType sh set foldmethod=marker
autocmd FileType tex set foldmarker={{{,}}} foldmethod=marker
autocmd FileType thrift set foldmethod=marker

" some other file type specific things
autocmd FileType html set shiftwidth=2 softtabstop=2
autocmd FileType jsp set shiftwidth=2 softtabstop=2
" I prefer rest syntax
autocmd FileType rst set syntax=rest
autocmd FileType ruby set shiftwidth=2 softtabstop=2
autocmd FileType tex set shiftwidth=2 softtabstop=2 textwidth=79

" when editing a file, always jump to the last cursor position
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

" Function to set the screen title
function! SetTitle()
    " replace $HOME with ~
    let l:filename = substitute(expand('%:p'), '^' . expand('$HOME'), '~', '')
    " but if here is a symlink to $HOME, then rather use expand('~')
    let l:filename = substitute(l:filename, '^' . expand('~'), '~', '')
    " now escape "
    let l:filename = substitute(l:filename, "\"", "\\\\\"", '')
    let l:title = 'vim - ' . l:filename
    " let l:truncTitle = strpart(l:title, 0, 15)
    " echo l:title
    silent exe '!echo -e -n "\033k' . l:title . '\033\\"'
    " if $TERM =~ 'xterm'
        " exe 'redraw!'
    " endif
endfunction

" Run it every time we change buffers
" autocmd BufEnter * call SetTitle()

