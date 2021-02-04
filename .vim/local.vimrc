if colors_name == "xoria256"
    hi Folded                                  ctermbg=234  guibg=#1c1c1c
    hi CursorLine                              ctermbg=235  guibg=#262626
    hi Visual       ctermfg=NONE   guifg=NONE  ctermbg=238  guibg=#444444
endif

" brew install socat
" let g:clipper_command='socat TCP:localhost:8377 STDIN'

" newer versions of netcat don't automatically close the socket...
let g:clipper_command='netcat -N localhost 8377'

let g:gh_trace = 1
let g:gh_open_command = 'fn() { echo "$@" | '.g:clipper_command.'; }; fn '
