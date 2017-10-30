if exists("did_load_filetypes")
  finish
endif

" some file type detection
augroup filetypedetect
  autocmd BufNewFile,BufRead *.frag,*.vert,*.fp,*.vp,*.glsl,*.fsh,*.vsh setfiletype glsl
  autocmd BufNewFile,BufRead *.as setfiletype actionscript
  autocmd BufNewFile,BufRead *.bzl setfiletype python
  autocmd BufNewFile,BufRead *.jbuilder setfiletype ruby
  autocmd BufNewFile,BufRead *.mxml setfiletype mxml
  autocmd BufNewFile,BufRead *.tex setfiletype tex
  autocmd BufNewFile,BufRead *.mako setfiletype mako
  autocmd BufNewFile,BufRead *.md setfiletype markdown
  autocmd BufNewFile,BufRead *.mm setfiletype objcpp
  autocmd BufNewFile,BufRead *.thrift setfiletype thrift
  autocmd BufNewFile,BufRead *.ts,*.tsx setfiletype javascript
  autocmd BufNewFile,BufRead BUCK setfiletype python shiftwidth=2 softtabstop=2
  autocmd BufNewFile,BufRead BUILD setfiletype python
augroup end
