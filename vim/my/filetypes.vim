augroup my_filetypes
    autocmd!
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
augroup END
