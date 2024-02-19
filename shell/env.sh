# shellcheck shell=bash

if type nvim &>/dev/null; then
    EDITOR='nvim'
elif type vim &>/dev/null; then
    EDITOR='vim'
elif type nano &>/dev/null; then
    EDITOR='nano'
elif type vi &>/dev/null; then
    EDITOR='vi'
fi
export EDITOR

export PAGER=less
export LESS="-R --mouse"
export LESSUTFCHARDEF="\
23fb-23fe:p,2665:p,26a1:p,2b58:p,e000-e00a:p,e0a0-e0a2:p,e0a3:p,\
e0b0-e0b3:p,e0b4-e0c8:p,e0ca:p,e0cc-e0d4:p,e200-e2a9:p,e300-e3e3:p,\
e5fa-e6a6:p,e700-e7c5:p,ea60-ebeb:p,f000-f2e0:p,f300-f32f:p,f400-f532:p,\
f500-fd46:p,f0001-f1af0:p"

export BASE16_THEME_DEFAULT=outrun-dark

export BAT_THEME=base16-256
export BAT_STYLE=numbers,grid
# accomodate for "less -J"
# alias bat="bat --terminal-width -2"

if type nnn &>/dev/null; then
    NNN_PLUGINS_PATH="$HOME/.config/nnn/plugins"
    export NNN_OPTS="acdQ"
    export NNN_OPENER="$NNN_PLUGINS_PATH/nuke"
    export NNN_PLUG="p:preview-tui;j:autojump"
    export NNN_COLORS="#b1b1b1b1;5555"
    #  1. block device
    #  2. char device
    #  3. directory
    #  4. executable
    #  5. regular
    #  6. hard link
    #  7. symbolic link
    #  8. missing OR file details
    #  9. orphaned symbolic link
    # 10. FIFO
    # 11. socket
    # 12. unknown OR 0B regular/exe
    #                   1 2 3 4 5 6 7 8 9 0 1 2
    export NNN_FCOLORS='c1e2b12e006033f7c6d6abc4'
    # XXX: iconlookup is broken with Nerd Fonts v3+
    export NNN_ICONLOOKUP=0
    [ -n "$TERM" ] && export NNN_TERMINAL="$TERM"
    unset NNN_PLUGINS_PATH
fi

# fix for okular icons
export QT_QPA_PLATFORMTHEME=qt5ct

# Locale settings
if [ -z "$LANG" ]; then
    if [ -f /.dockerenv ]; then
        export LANG=C.UTF-8
    else
        export LC_CTYPE=en_US.UTF-8
        export LC_ALL=en_US.UTF-8
    fi
fi
