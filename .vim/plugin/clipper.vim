" brew install clipper
let g:clipper_command=get(g:, 'clipper_command', 'socat localhost 8377')
function Clip()
  call system(g:clipper_command, @0)
endfunction

command! Clip call Clip()

" for sharing copy buffer and clipboard over ssh
" couples with ssh-forwarding port 8377 and clipper
nnoremap <leader>y :Clip<CR>
vnoremap <leader>y y:Clip<CR>
