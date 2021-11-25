# shellcheck shell=bash

show-off() {
    clear && python3 -c "print('\n' * 6)" && neofetch "$@" && python3 -c "print('\n' * 6)"
}

vusec-show-off() {
    show-off --source ~/vusec.ascii --ascii_colors 0 1 2 3 4 5 6 7 8
}

md-read-as-html() {
    pandoc -t html "$1" | lynx -stdin
}

md-read-as-pdf() {
    if [ ! -e "$1" ]; then
        >&2 echo "Not a file: $1"
        return 1
    fi
    local tmpf
    tmpf=$(mktemp)
    local tmpf_pdf="$tmpf.pdf"
    pandoc -o "$tmpf_pdf" "$1" || return 1
    if [ "$(uname)" = Darwin ]; then
        open "$tmpf_pdf"
    else
        zathura --fork - < "$tmpf_pdf"
    fi
    rm "$tmpf" "$tmpf_pdf"
}

pdfread() {
    zathura --fork "$@"
}

picshow() {
    nohup sxiv "$@" > /dev/null &
}

_editor-help() {
    local ed=$1 init_q=$2 tags selection
    case ${ed} in
        vim)
            tags="/usr/share/vim/vim82/doc/tags"
            [ -r "$tags" ] || tags="/usr/share/vim/vim81/doc/tags"
            ;;
        nvim)
            tags=$(cd "$(dirname "$(which nvim)")/../share/nvim/runtime/doc/" && pwd)/tags ;;
        *)
            eecho "Editor $ed not supported"
            return 1
            ;;
    esac
    [ -r "$tags" ] || { eecho "File $tags is not valid for $ed!"; return 1; }
    selection=$(awk '{printf "%-40s\t%s\n", $2, $1}' "$tags" \
        | fzf --height=50% --layout=reverse --query="$init_q" \
        | cut -d$'\t' -f2)
    [ -n "$selection" ] || return 0
    "$ed" "+:vert :help $selection" "+:vert resize" -
}

alias vim-help="_editor-help vim"
alias nvim-help="_editor-help nvim"

# Platform specific
case $(uname) in
    Linux)
        # shellcheck source=shell/functions_linux.sh
        source ~/.shell/functions_linux.sh
        ;;
esac
