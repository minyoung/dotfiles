" some file type detection
autocmd BufNewFile,BufRead *.frag,*.vert,*.fp,*.vp,*.glsl,*.fsh,*.vsh set filetype=glsl
autocmd BufNewFile,BufRead *.as set filetype=actionscript
autocmd BufNewFile,BufRead *.mxml set filetype=mxml
autocmd BufNewFile,BufRead *.tex set filetype=tex
autocmd BufNewFile,BufRead *.mako set filetype=mako
autocmd BufNewFile,BufRead *.thrift set filetype=thrift

" foldmethods
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
autocmd FileType javascript set shiftwidth=2 softtabstop=2
autocmd FileType jsp set shiftwidth=2 softtabstop=2
autocmd FileType php set shiftwidth=2 softtabstop=2
autocmd FileType rst set syntax=rest
autocmd FileType ruby set shiftwidth=2 softtabstop=2
autocmd FileType tex set shiftwidth=2 softtabstop=2 textwidth=79
