" Useful utilities

command! DiffOrig vert new | set buftype=nofile | read ++edit # | 0d_
        \ | diffthis | wincmd p | diffthis

" Highlights parts that belong to the same highlighting group (see also treesitter's :Inspect)
command! -complete=highlight -nargs=1
        \ HighlightHighlight execute 'highlight! link ' . <q-args> . ' Search'

function! MoveToPrevTab()
    "there is only one window
    if tabpagenr('$') == 1 && winnr('$') == 1
        return
    endif
    "preparing new window
    let l:tab_nr = tabpagenr('$')
    let l:cur_buf = bufnr('%')
    if tabpagenr() != 1
        close!
        if l:tab_nr == tabpagenr('$')
            tabprev
        endif
        sp
    else
        close!
        exe "0tabnew"
    endif
    "opening current buffer in new window
    exe "b".l:cur_buf
endfunc

function! MoveToNextTab()
    "there is only one window
    if tabpagenr('$') == 1 && winnr('$') == 1
        return
    endif
    "preparing new window
    let l:tab_nr = tabpagenr('$')
    let l:cur_buf = bufnr('%')
    if tabpagenr() < tab_nr
        close!
        if l:tab_nr == tabpagenr('$')
            tabnext
        endif
        sp
    else
        close!
        tabnew
    endif
    "opening current buffer in new window
    exe "b".l:cur_buf
endfunc

let g:scratch_bufname = 'scratch'
function! Scratch(fresh)
    if bufname() == g:scratch_bufname
        return
    endif
    let l:scratch = bufnr(g:scratch_bufname)
    if l:scratch != -1
        if a:fresh == 1
            exe l:scratch . 'bwipe'
        else
            exe 'vsplit' g:scratch_bufname
            return
        endif
    endif
    vsplit
    noswapfile hide enew
    setlocal buftype=nofile
    setlocal bufhidden=hide
    "setlocal nobuflisted
    "lcd ~
    exe 'file' g:scratch_bufname
endfunction
