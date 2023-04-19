# shellcheck shell=bash

alias mouse-here='xdotool mousemove --window `xdotool getwindowfocus` 20 20'

alias dzen-toggle="kill -USR1 \$(pidof dzen2)"
# alias dzen-ungrab="kill -USR2 \$(pidof dzen2)"

nmcli-connect() {
    local uuid
    uuid=$(nmcli -g connection.uuid c show "$1" 2>/dev/null)
    [ -z "$uuid" ] && echo >&2 "Cannot find UUID for '$1'" && return 1
    nmcli connection up "$uuid"
}

desk_setup() {
    case "$1" in
    vusec)
        "$HOME/.screenlayout/vusec-desk.sh"
        lux -S 100% >/dev/null
        ;;
    home)
        "$HOME/.screenlayout/home.sh"
        lux -S 70% >/dev/null
        ;;
    *)
        echo >&2 "Unrecognized desk"
        return 1
        ;;
    esac
    "$HOME/.fehbg"
    vusec-show-off
    echo "$1 desk setup"
}
