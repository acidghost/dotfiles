# Setup fzf
# ---------
if [[ ! "$PATH" == *$HOME/.vim/plugged/fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}$HOME/.vim/plugged/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "$HOME/.vim/plugged/fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "$HOME/.vim/plugged/fzf/shell/key-bindings.zsh"

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
    res=`zshz -l 2>&1 | fzf --tac --preview 'tree -aC --gitignore -I .git {2}' --reverse`
    [ $? -eq 0 ] && {
        local p=`echo -n "$res" | sed 's/^[0-9]*\.*[0-9]*[[:space:]]*\/\(.*\)$/\/\1/'`
        zle reset-prompt
        LBUFFER+="cd $p"
    }
}
zle     -N   _z_jump
bindkey '^j' _z_jump
