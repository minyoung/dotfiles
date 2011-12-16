" Function to set the screen title
" still needs more work...
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
    " silent exe '!echo -e -n "\033k' . l:title . '\033\\"'
endfunction

" Run it every time we change buffers
" autocmd BufEnter * call SetTitle()

