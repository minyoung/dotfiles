if colors_name == "xoria256"
    hi Folded                                    ctermbg=234  guibg=#1c1c1c
    hi CursorLine                                ctermbg=235  guibg=#262626
    hi Visual       ctermfg=NONE  guifg=NONE     ctermbg=238  guibg=#444444
    hi CocFloating  ctermfg=252   guifg=#d0d0d0  ctermbg=237  guibg=#3a3a3a
endif

set wildignore+=node_modules,dist,coverage,trajectories

set colorcolumn=0

" brew install socat
" let g:clipper_command='socat TCP:localhost:8377 STDIN'

" newer versions of netcat don't automatically close the socket...
let g:clipper_command='netcat -N localhost 8400'

let g:gh_trace = 1
let g:gh_open_command = 'fn() { echo "$@" | '.g:clipper_command.'; }; fn '
" let g:gh_use_canonical = 1

autocmd BufNewFile,BufRead *.launch setfiletype xml
