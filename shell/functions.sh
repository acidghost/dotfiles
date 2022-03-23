# shellcheck shell=bash

show-off() {
    clear && perl -e 'print "\n"x6' && neofetch "$@" && perl -e 'print "\n"x6'
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
    local ed=$1 init_q=$2 tags selection f
    case ${ed} in
        vim)
            tags="/usr/share/vim/vim82/doc/tags"
            [ -r "$tags" ] || tags="/usr/share/vim/vim81/doc/tags"
            ;;
        nvim)
            tags=$(cd "$(dirname "$(which nvim)")/../share/nvim/runtime/doc/" && pwd)/tags ;;
        *)
            >&2 echo "Editor $ed not supported"
            return 1
            ;;
    esac
    [ -r "$tags" ] || { >&2 echo "File $tags is not valid for $ed!"; return 1; }
    f=$(mktemp) || { >&2 echo "Cannot create temp file"; return 1; }
    selection=$(awk '{printf "%-40s\t%s\n", $2, $1}' "$tags" \
        | fzf --height=50% --layout=reverse --query="$init_q" \
        | cut -d$'\t' -f2)
    [ -n "$selection" ] && "$ed" "+:vert :help $selection" "+:vert resize" "$f"
    rm "$f"
}

alias vim-help="_editor-help vim"
alias nvim-help="_editor-help nvim"

# http://unix.stackexchange.com/a/269085/67282
hex-to-256() {
    local hex=$1 r g b
    if [[ $hex == "#"* ]]; then
        hex=$(echo "$1" | awk '{print substr($0,2)}')
    fi
    r=$(printf '0x%0.2s' "$hex")
    g=$(printf '0x%0.2s' "${hex#??}")
    b=$(printf '0x%0.2s' "${hex#????}")
    echo -e "$(printf "%03d" "$(( (r < 75 ? 0 : (r - 35) / 40) * 6 *6 +
                                  (g < 75 ? 0 : (g - 35) / 40) * 6    +
                                  (b < 75 ? 0 : (b - 35) / 40)        + 16 ))")"
}

256-to-hex() {
    local r g b gray
    local dec=$(( $1 % 256 ))
    if [ "$dec" -lt 16 ]; then
        local bas=$(( dec % 16 ))
        local mul=128
        [ "$bas" -eq 7 ] && mul=192
        [ "$bas" -eq 8 ] && bas=7
        [ "$bas" -gt 8 ] && mul=255
        printf '#%02x%02x%02x\n' \
            "$((   (bas & 1)        * mul ))" \
            "$(( ( (bas & 2) >> 1 ) * mul ))" \
            "$(( ( (bas & 4) >> 2 ) * mul ))"
    elif [ "$dec" -gt 15 ] && [ "$dec" -lt 232 ]; then
        b=$(( (dec - 16) % 6    )); b=$(( b == 0 ? 0 : b * 40 + 55 ))
        g=$(( (dec - 16) / 6 % 6)); g=$(( g == 0 ? 0 : g * 40 + 55 ))
        r=$(( (dec - 16) / 36   )); r=$(( r == 0 ? 0 : r * 40 + 55 ))
        printf '#%02x%02x%02x\n' "$r" "$g" "$b"
    else
        gray=$(( (dec - 232) * 10 + 8 ))
        printf 'dec= %3s  gray= #%02x%02x%02x\n' "$dec" "$gray" "$gray" "$gray"
    fi
}

hex-to-rgb() {
    local hex=$1 join=$2 hr hg hb
    [[ "$hex" =~ ^# ]] && hex=$(cut -c2- <<< "$hex")
    [ "${#hex}" -lt 6 ] && { >&2 echo "invalid hex color"; return 1; }
    [ -z "$join" ] && join=' '
    hr=$(cut -c1-2 <<< "$hex")
    hg=$(cut -c3-4 <<< "$hex")
    hb=$(cut -c5-6 <<< "$hex")
    printf '%d%s%d%s%d' "0x$hr" "$join" "0x$hg" "$join" "0x$hb"
}

# Create a local port forwarding on the remote server (i.e. you can access
# remote host port as if it was local). Use aliases `ssh-ctrl-$cmd` to control
# the session.
ssh-forward-local() {
    local host=$1 params=(-L "${2}:localhost:${2}")
    if [ -z "$host" ] || [ -z "$2" ]; then
        echo "usage: ssh-forward-local host port [port...]"
        return 1
    fi
    if ! (ssh -G "$host" | grep -q "controlpath"); then
        echo "Expected option ControlPath to be set for $host"
        return 1
    fi
    shift 2
    while [ -n "$1" ]; do
        params+=(-L "${1}:localhost:${1}")
        shift
    done
    ssh -fNTM "${params[@]}" "$host"
}

twitch-search-vods() {
    if [[ -z "$1" || "$1" = -h || "$1" = -help || "$1" = --help ]]; then
        echo "$0 [fg | nochat] channel"
        return 0
    fi
    local cmd='mpv --terminal=no {} &'
    if [ "$1" = "fg" ]; then
        cmd="mpv {}"
        shift
    elif [ "$1" = "nochat" ]; then
        cmd="$cmd echo {}"
        shift
    else
        cmd="$cmd vod-chat -mpv -vod={}"
    fi
    # shellcheck disable=SC2016
    local preview='twitch api get videos -q id=$(sed -E "s,^.*/([0-9]+)$,\1," <<< {1}) | \
        jq -c ".data[0]" | pprint-json-obj id duration view_count published_at title url user_name'
    twitch-search -vod="$1" \
        | fzf --ansi --height=50% --layout=reverse \
              --preview="$preview" --preview-window='hidden,border-none' \
              --bind='ctrl-p:toggle-preview' \
        | awk '{print $1}' \
        | xargs -I{} -o /bin/sh -c "$cmd"
}

twitch-search-live() {
    if [[ "$1" = -h || "$1" = -help || "$1" = --help ]]; then
        echo "$0 [fg | nochat]"
        return 0
    fi
    local cmd='mpv --terminal=no https://twitch.tv/{} &'
    if [ "$1" = "fg" ]; then
        cmd="mpv https://twitch.tv/{}"
        shift
    elif [ "$1" = "nochat" ]; then
        cmd="$cmd echo {}"
        shift
    else
        cmd="$cmd vod-chat -live={}"
    fi
    local preview='twitch api get search/channels -q query={1} -q first=1 | \
        jq -c ".data[0]" | pprint-json-obj id display_name title game_name started_at'
    twitch-search -live \
        | fzf --ansi --height=50% --layout=reverse \
              --preview="$preview" --preview-window='hidden,border-none' \
              --bind='ctrl-p:toggle-preview' \
        | awk '{print $1}' \
        | xargs -I{} -o /bin/sh -c "$cmd"
}

# shellcheck disable=SC2032     # we don't want this to be used by xargs
vgrep() {
    local initial_query="$1" vgrep_prefix="vgrep --no-header "
    # shellcheck disable=SC2016
    local preview='
        l={3} f={2}
        [ "$l" -gt 3 ] && ll=$((l - 3))
        exec bat --color always -n -H "$l" -r "$ll:" "$f"'
    # shellcheck disable=SC2033     # we don't want the function but the binary
    FZF_DEFAULT_COMMAND="$vgrep_prefix '$initial_query'" \
        fzf --bind "change:reload:$vgrep_prefix {q} || true" --preview "$preview" \
            --ansi --phony --tac --query "$initial_query" \
        | awk '{print $1}' | xargs -I{} -o vgrep --show {}
}

# Platform specific
case $(uname) in
    Linux)
        # shellcheck source=shell/functions_linux.sh
        source ~/.shell/functions_linux.sh
        ;;
esac
