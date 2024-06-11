# shellcheck shell=bash

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias ll='ls -lh'
alias la='ls -Alh'
alias l='ls -alh'

alias ta='tmux attach'
alias tat='tmux attach -t'
alias ts='tmux new-session -s'
alias tsh='tmux new-session -s "$(basename "$PWD")"'

alias ga='git add'
alias gd='git diff'
alias gds='git diff --staged'
alias gc='git commit --verbose'
alias gf='git fetch'
alias gl='git pull'
alias gst='git status'
alias glo='git log --oneline'

alias e='$EDITOR'
# alias objdump='objdump -M intel'

for i in $(seq 10); do
    # shellcheck disable=SC2139
    alias "tree$i=tree -L $i"
    # shellcheck disable=SC2139
    alias "dh$i=du -h -d $i"
done
unset i

alias rgrep='rgrep --color=auto -n'
alias tabcsv='column -s, -t'
alias tabtsv="column -s$'\t' -t"

for cmd in check exit; do
    # shellcheck disable=SC2139
    alias "ssh-ctrl-$cmd=ssh -TO $cmd"
done
unset cmd
alias ssh-ctrl-list="ls -l ~/.ssh/*.ctl"

alias rsync-repo="rsync -rlptzv --progress --include='**.gitignore' --filter=':- .gitignore' --delete-after"
alias rsync-all="rsync -rlptzv --progress --delete"

type jless &>/dev/null && alias yless='jless --yaml'
type jq &>/dev/null && alias jqc='jq --color-always'

# set aliases for programs packaged under a different name (e.g. in ubuntu)
if ! type fd &>/dev/null && type fdfind &>/dev/null; then alias fd=fdfind; fi

type bat &>/dev/null && alias batpage='bat --paging=always'

type lsd &>/dev/null && alias ls=lsd

type kubectl &>/dev/null && alias k=kubectl

# Platform specific
case $OSTYPE in
linux*)
    # shellcheck source=shell/aliases_linux.sh
    source ~/.shell/aliases_linux.sh
    ;;
esac
