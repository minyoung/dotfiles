set nocompatible

" git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
set rtp+=~/.vim
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" Vundle, the plug-in manager for Vim
" https://github.com/VundleVim/Vundle.vim
Plugin 'VundleVim/Vundle.vim'

" Command-line fuzzy finder
" https://github.com/junegunn/fzf
Plugin 'junegunn/fzf'

" A tree explorer plugin for vim
" https://github.com/scrooloose/nerdtree
Plugin 'scrooloose/nerdtree'

" Vim plugin for intensely orgasmic commenting
" https://github.com/scrooloose/nerdcommenter
Plugin 'scrooloose/nerdcommenter'

" xoria256: Soft pastel gamma on dark background
" https://github.com/noah/vim256-color.git
Plugin 'noah/vim256-color'

" Perform all your vim insert mode completions with Tab
" https://github.com/ervandew/supertab
" Plugin 'ervandew/supertab'

" A Git wrapper so awesome, it should be illegal
" https://github.com/tpope/vim-fugitive.git
Plugin 'tpope/vim-fugitive'

" Quoting/parenthesizing made simple
" https://github.com/tpope/vim-surround
Plugin 'tpope/vim-surround'

" Intelligently reopen files at your last edit position
" https://github.com/farmergreg/vim-lastplace.git
Plugin 'farmergreg/vim-lastplace'

" Open the link of current line on github
" https://github.com/ruanyl/vim-gh-line
Plugin 'ruanyl/vim-gh-line'

" Intellisense engine for vim8 & neovim, full language server protocol support as VSCode
" https://github.com/neoclide/coc.nvim
Plugin 'neoclide/coc.nvim'

" Go development plugin for Vim
" https://github.com/fatih/vim-go
" Plugin 'fatih/vim-go'

Plugin 'leafgarland/typescript-vim'
Plugin 'peitalin/vim-jsx-typescript'

Plugin 'simnalamburt/vim-mundo'

call vundle#end()

let mapleader=","

noremap <F1> <esc>
inoremap jj <esc>
inoremap kk <esc>

" very magic search by default
nnoremap / /\v
vnoremap / /\v

" pretty colors and looks
" try my preferred colorscheme first (xoria256),
" if that fails, then use a default colorscheme that *should* be present
if &t_Co == 256 || has("gui_running")
  colorscheme xoria256
else
  colorscheme delek
endif
syntax on
syn sync fromstart
set synmaxcol=120

" I don't like hunting for a small cursor
set cursorline

" only have cursorline in the current window
autocmd WinLeave * set nocursorline
autocmd WinEnter * set cursorline

" sometimes WinEnter isn't triggered, so here's a backup
map <leader>l :set cursorline<cr>

" sometimes I get garbage on the screen...
nmap <leader>r :redraw!<cr>

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

" searching, incsearch is amazing
set incsearch
" hlsearch is useful, but the highlighting staying around is annoying, so
" that's what the next mapping is for :D
set hlsearch
nnoremap <esc> <esc>:nohlsearch<cr><esc>

" useful for searching
set ignorecase
set smartcase
set infercase

" folding
set foldenable

" just set the default foldmarker to {,}, which is the most common
" filetypes.vimrc will set foldmethod as appropriate
set foldmarker={,}
" set foldmethod=marker
" shortcut key to help with manual folding
vmap <leader>f :fold<CR>

" Don't screw up folds when inserting text that might affect them, until
" leaving insert mode. Foldmethod is local to the window.
autocmd InsertEnter * let w:last_fdm=&foldmethod | setlocal foldmethod=manual
autocmd InsertLeave * let &l:foldmethod=w:last_fdm

" toggle fold with space
nnoremap <space> za

" tab stuff
set expandtab
set shiftwidth=2
set softtabstop=2
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
set wildmode=longest:full
set wildignore=*.o,*.obj,*.bak,*.class,*.pyc,*.swp,.git,.hg,_bin

" make the clipboard the default register to use
" set clipboard=unnamed,exclude:cons\|linux

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
" set statusline+=%-3.3n
" set statusline+=%f
" set statusline+=%h%m%r%w
" set statusline+=[%{strlen(&ft)?&ft:'none'}]
" set statusline+=%=
" set statusline+=0x%-8B
" set statusline+=%-14(%l,%c%V%)
" set statusline+=%<%P

" setlocal spell spelllang=en

" couldn't be bothered with the extra backup and swap files
set nobackup
set noswapfile

" really liking the ability to jump to definition: <C-]>
set tags=tags;/

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

" 'scroll' up/down faster
nnoremap <C-e> 5<C-e>
nnoremap <C-y> 5<C-y>

" useful remappings
" noremap 0 ^
" noremap ^ 0
noremap ` '
noremap ' `
noremap _ g_

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

" number the lines
if exists('+relativenumber')
    set relativenumber
else
    set number
endif
set numberwidth=5

" random
set hidden
set winaltkeys=no
nmap K <nop>

" write with sudo
cnoremap w!! w !sudo tee % >/dev/null

" mksession
" I just don't want blank, help and options
set sessionoptions=buffers,curdir,folds,tabpages,winsize

" persistent undo
if exists("+undofile")
  set undodir=~/.vim/undodir
  set undofile
endif

" highlight things over 80 columns
if exists('+colorcolumn')
  set colorcolumn=81
  highlight ColorColumn ctermbg=52 guibg=#5f0000
else
  highlight OverLength ctermbg=darkred ctermfg=white
  function! HighlightCode()
    match OverLength '\%81v'
  endfunction
  call HighlightCode()
  " wrap in function so that it works for splits
  autocmd WinEnter * call HighlightCode()
  " autocmd BufWinEnter * let w:m1=matchadd('OverLength', '\%81v', -1)
endif

" when editing a file, always jump to the last cursor position
" autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

" Function to set the screen title
function! SetTitle()
  " get current filename, replacing ' with \'
  let l:filename = substitute(expand('%:~:.'), "'", '\\''', '')
  let l:title = 'vim - ' . l:filename
  " let l:truncTitle = strpart(l:title, 0, 15)
  silent exe "!set_title.sh '" . l:title . "'"
endfunction

" Run it every time we change buffers
" autocmd BufEnter * call SetTitle()
set title
set titlestring=%f

" my color overrides
if colors_name == "xoria256"
  highlight Folded                                  ctermbg=234  guibg=#1c1c1c
  highlight CursorLine                              ctermbg=235  guibg=#262626
  highlight Visual      ctermfg=NONE guifg=NONE     ctermbg=238  guibg=#444444
  highlight LineNr      ctermfg=240  guifg=#585858  ctermbg=234  guibg=#1c1c1c
endif


" nerd_commenter
map <leader>; ,c<space>
let NERDSpaceDelims=1

" nerd_tree
nmap <leader>n :NERDTreeToggle<CR>
nmap <leader>f :NERDTreeFind<CR>
let NERDTreeShowBookmarks=1
let NERDTreeBookmarksFile=expand("$HOME/.vim/NERDTreeBookmarks")
let NERDTreeConfirmDeleteBookmark=0

" fzf
nmap <leader>t :FZF<CR>
nmap <leader>m :Buffers<CR>

" SuperTab
" let g:SuperTabDefaultCompletionType='<c-n>'
" let g:SuperTabLongestEnhanced=1

" YCM
set completeopt-=preview
let g:ycm_add_preview_to_completeopt = 0

" vim-go
" disable vim-go :GoDef short cut (gd)
" this is handled by LanguageClient [LC]
let g:go_def_mapping_enabled = 0
let g:go_fmt_command = "goimports"

" CoC
" set signcolumn=yes
set updatetime=300
autocmd CursorHold * silent call CocActionAsync('highlight')

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

nnoremap <silent> K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction
" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

nmap <leader>rn <Plug>(coc-rename)

" helper files
if filereadable(expand("$HOME/.vim/ftplugin.vim"))
  source $HOME/.vim/ftplugin.vim
end
if filereadable(expand("$HOME/.vim/local.vimrc"))
  source $HOME/.vim/local.vimrc
end
