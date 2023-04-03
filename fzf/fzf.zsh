# Setup fzf
# ---------
# Only add vim-plug managed version if not otherwise installed
plugged_path="$HOME/.vim/plugged/fzf"
if [ -n "$commands[fzf]" ]; then
    case ${OSTYPE} in
        darwin*)    fzf_prefix=/opt/homebrew/opt/fzf        ;;
        linux*)     fzf_prefix=/usr/share/fzf               ;;
        *)          fzf_prefix="$plugged_path"              ;;
    esac
    [ ! -d "$fzf_prefix" ] && fzf_prefix="$plugged_path"
else
    if [[ ! "$PATH" == *$plugged_path/bin* ]] && [[ -d "$plugged_path/bin" ]]; then
        export PATH="${PATH:+${PATH}:}$plugged_path/bin"
        fzf_prefix="$plugged_path"
    fi
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "$fzf_prefix/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "$fzf_prefix/shell/key-bindings.zsh"

export FZF_TMUX=1
export FZF_DEFAULT_COMMAND="fd --type f"
[ -f ~/.fzf_theme ] && source ~/.fzf_theme

_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf "$@" --preview 'tree -aC --gitignore {}' ;;
    export|unset) fzf "$@" --preview "eval 'echo \$'{}" "$@" ;;
    ssh)          fzf "$@" --preview 'dig {}' ;;
    $EDITOR)      fzf "$@" --preview 'bat --color always -p {}' ;;
    *)            fzf "$@" ;;
  esac
}

_z_jump() {
    local res
    if [ -n "$commands[zoxide]" ]; then
        res=$(zoxide query -i -- "$@")
        [ $? -eq 0 ] && {
            LBUFFER+="cd $res"
        }
        zle redisplay
    else
        res=`zshz -l 2>&1 | fzf --tac --preview 'tree -aC --gitignore -I .git {2}' --reverse`
        [ $? -eq 0 ] && {
            local p=`echo -n "$res" | sed 's/^[0-9]*\.*[0-9]*[[:space:]]*\/\(.*\)$/\/\1/'`
            zle reset-prompt
            LBUFFER+="cd $p"
        }
    fi
}
zle     -N   _z_jump
bindkey '^j' _z_jump

unset plugged_path fzf_prefix
