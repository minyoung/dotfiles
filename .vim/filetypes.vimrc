" some file type detection
autocmd BufNewFile,BufRead *.frag,*.vert,*.fp,*.vp,*.glsl,*.fsh,*.vsh set filetype=glsl
autocmd BufNewFile,BufRead *.as set filetype=actionscript
autocmd BufNewFile,BufRead *.jbuilder set filetype=ruby
autocmd BufNewFile,BufRead *.mxml set filetype=mxml
autocmd BufNewFile,BufRead *.tex set filetype=tex
autocmd BufNewFile,BufRead *.mako set filetype=mako
autocmd BufNewFile,BufRead *.mm set filetype=objcpp
autocmd BufNewFile,BufRead *.thrift set filetype=thrift
autocmd BufNewFile,BufRead *.ts set filetype=javascript
autocmd BufNewFile,BufRead BUCK set filetype=python shiftwidth=2 softtabstop=2

" foldmethods
autocmd FileType actionscript set foldmethod=marker
autocmd FileType c set foldmethod=syntax
autocmd FileType cpp set foldmethod=syntax
autocmd FileType cs set foldmethod=syntax
autocmd FileType css set foldmethod=marker
autocmd FileType go set foldmethod=marker
autocmd FileType html set foldmethod=indent
autocmd FileType java set foldmethod=marker
autocmd FileType javascript set foldmethod=marker
autocmd FileType nerdtree set nofoldenable
autocmd FileType objc set foldmethod=marker
autocmd FileType objcpp set foldmethod=marker
autocmd FileType php set foldmethod=indent
autocmd FileType python set foldmethod=indent
autocmd FileType ruby set foldmethod=syntax
autocmd FileType sh set foldmethod=marker
autocmd FileType tex set foldmarker={{{,}}} foldmethod=marker
autocmd FileType thrift set foldmethod=marker

" some other file type specific things
autocmd FileType cpp set shiftwidth=2
autocmd FileType eruby set shiftwidth=2
autocmd FileType go set noexpandtab shiftwidth=8
autocmd FileType html set shiftwidth=2 softtabstop=2
autocmd FileType javascript set shiftwidth=2 softtabstop=2
autocmd FileType jsp set shiftwidth=2 softtabstop=2
autocmd FileType php set shiftwidth=2 softtabstop=2
autocmd FileType python set shiftwidth=4 softtabstop=4
autocmd FileType rst set syntax=rest
autocmd FileType ruby set shiftwidth=2 softtabstop=2
autocmd FileType tex set shiftwidth=2 softtabstop=2 textwidth=79
autocmd FileType objc set shiftwidth=2 softtabstop=2
autocmd FileType yaml set shiftwidth=2 softtabstop=2

autocmd FileType qf set nofoldenable

autocmd FileType go set colorcolumn=0 nolist
autocmd FileType objc set colorcolumn=0 nowrap
autocmd FileType objcpp set colorcolumn=0 nowrap
