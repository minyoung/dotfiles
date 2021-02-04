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
autocmd FileType yaml set foldmethod=indent

" some other file type specific things
autocmd FileType go set noexpandtab shiftwidth=8
autocmd FileType python set shiftwidth=4 softtabstop=4
autocmd FileType rst set syntax=rest
autocmd FileType tex set textwidth=79

autocmd FileType qf set nofoldenable

autocmd FileType go set colorcolumn=0 nolist
autocmd FileType objc set colorcolumn=0 nowrap
autocmd FileType objcpp set colorcolumn=0 nowrap
