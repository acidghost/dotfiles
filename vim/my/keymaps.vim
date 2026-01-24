""" Key mappings

" Yank to PRIMARY clipboard
noremap <Leader>y "*y
" Paste from PRIMARY clipboard
noremap <Leader>p "*p
" Yank to CLIPBOARD clipboard
noremap <Leader>Y "+y
" Paste from CLIPBOARD clipboard
noremap <Leader>P "+p

" Navigate quickfix list
noremap <Leader>eo :botright copen<CR>
noremap <Leader>ef :cfirst<CR>
noremap <Leader>en :cnext<CR>
noremap <Leader>ep :cprevious<CR>

nmap <Down> <C-E>
nmap <Up> <C-Y>
nmap <Left> 20zl
nmap <Right> 20zr

nmap <C-s> :Obsession<CR>
nmap <C-s>s :Prosession<Space>
nmap <C-s>d :ProsessionDelete<CR>

noremap <Leader>@ :nohl<CR>
noremap <Leader>w :setl wrap!<CR>

noremap <Leader>d :e %/..<CR>
noremap <Leader>D :e .<CR>

noremap <C-w>gn :tabnew %<CR>

nmap <Leader>c :%bd\|edit#\|bd#<CR>
nmap <Leader>C :%bd<CR>

imap <silent> <c-p> <Plug>(completion_trigger)

nnoremap <C-w>. :call MoveToNextTab()<CR><C-w>H
nnoremap <C-w>, :call MoveToPrevTab()<CR><C-w>H

nnoremap <C-w>S :call Scratch(0)<CR>
nnoremap <C-w><C-s> :call Scratch(1)<CR>

nnoremap <Leader>gg :call ForgeUrl()<CR>
