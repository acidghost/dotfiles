autocmd BufRead,BufNewFile $HOME/.aliases set ft=sh
autocmd BufRead,BufNewFile $HOME/.path set ft=sh
autocmd BufRead,BufNewFile *.fc set ft=fennec
autocmd BufRead,BufNewFile *.ll set ft=llvm
autocmd BufRead,BufNewFile *.td set ft=tablegen
autocmd BufRead,BufNewFile *.rasi setf css
autocmd BufRead,BufNewFile Brewfile,Vagrantfile setf ruby
autocmd BufRead,BufNewFile *.vifm,vifmrc setf vim
autocmd BufRead,BufNewFile devcontainer.json set ft=jsonc
au VimEnter,BufWinEnter,BufRead,BufNewFile {.,}justfile\c,*.just setlocal filetype=just | setlocal commentstring=#\ %s

autocmd FileType go setlocal shiftwidth=4 tabstop=4 noexpandtab
autocmd FileType cpp setlocal shiftwidth=2 tabstop=2
autocmd FileType cmake setlocal shiftwidth=2 tabstop=2
autocmd FileType org setlocal shiftwidth=2 tabstop=2
autocmd FileType yaml setlocal shiftwidth=2 tabstop=2
autocmd FileType html setlocal shiftwidth=2 tabstop=2
autocmd FileType nu setlocal shiftwidth=2 tabstop=2

if has('nvim')
lua <<EOF
vim.filetype.add({
  extension = {
    gotmpl = 'gotmpl',
  },
  pattern = {
    [".*/templates/.*%.tpl"] = "helm",
    [".*/templates/.*%.ya?ml"] = "helm",
    ["helmfile.*%.ya?ml"] = "helm",
  },
})
EOF
endif
