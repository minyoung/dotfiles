function Clip()
  call system('nc localhost 8377', @0)
endfunction

command! Clip call Clip()

" for sharing copy buffer and clipboard over ssh
" couples with ssh-forwarding port 8377 and clipper
nnoremap <leader>y :Clip<CR>
vnoremap <leader>y y:Clip<CR>
