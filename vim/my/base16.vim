function! s:base16_customize() abort
    call Tinted_Hi("Identifier", g:tinted_gui05, "", g:tinted_cterm05, "", "none", "")
    call Tinted_Hi("Folded", g:tinted_gui02, "", g:tinted_cterm02, "", "none", "")
    call Tinted_Hi("MatchParen", "", g:tinted_gui03, "", g:tinted_cterm03, "none", "")
    call Tinted_Hi("@markup.raw", g:tinted_gui09, "", g:tinted_cterm09, "", "none", "")
    call Tinted_Hi("@markup.raw.block", g:tinted_gui09, "", g:tinted_cterm09, "", "none", "")
    call Tinted_Hi("@markup.link", g:tinted_gui0A, "", g:tinted_cterm0A, "", "none", "")
    call Tinted_Hi("@markup.link.label", g:tinted_gui0C, "", g:tinted_cterm0C, "", "bold", "")
    call Tinted_Hi("@markup.link.url", g:tinted_gui0E, "", g:tinted_cterm0E, "", "underline", "")
    call Tinted_Hi("@property.yaml", g:tinted_gui0E, "", g:tinted_cterm0E, "", "none", "")
    call Tinted_Hi("@string.yaml", g:tinted_gui0B, "", g:tinted_cterm0B, "", "none", "")
    highligh default link NeoTreeGitUntracked NeoTreeGitIgnored
    call Tinted_Hi("NeoTreeGitUnstaged", g:tinted_gui0A, "", g:tinted_cterm0A, "", "none", "")
    call Tinted_Hi("MiniIconsPurple", g:tinted_gui0F, "", g:tinted_cterm0F, "", "none", "")
    call Tinted_Hi("MiniIconsYellow", g:tinted_gui0A, "", g:tinted_cterm0A, "", "none", "")
    call Tinted_Hi("MiniIconsCyan", g:tinted_gui0C, "", g:tinted_cterm0C, "", "none", "")
endfunction

augroup on_change_colorschema
    autocmd!
    autocmd ColorScheme * call s:base16_customize()
augroup END

if exists('$BASE16_THEME')
    \ && (!exists('g:colors_name') || g:colors_name != 'base16-$BASE16_THEME')
    let tinted_colorspace=256
    colorscheme base16-$BASE16_THEME
endif
