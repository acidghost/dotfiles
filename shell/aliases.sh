# shellcheck shell=bash
# Aliases
alias ta='tmux attach'
alias tat='tmux attach -t'

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
alias tabtsv='column -s"\t" -t'

for cmd in check exit; do
    # shellcheck disable=SC2139
    alias "ssh-ctrl-$cmd=ssh -TO $cmd"
done
unset cmd
alias ssh-ctrl-list="ls -l ~/.ssh/*.ctl"

alias rsync-repo="rsync -ra --include='**.gitignore' --filter=':- .gitignore' --delete-after"

type jless &>/dev/null && alias yless='jless --yaml'
type jq &>/dev/null && alias jqc='jq --color-always'

# set aliases for programs packaged under a different name (e.g. in ubuntu)
if ! type bat &>/dev/null && type batcat &>/dev/null; then alias bat=batcat; fi
if ! type fd &>/dev/null && type fdfind &>/dev/null; then alias fd=fdfind; fi

# Platform specific
case $(uname) in
    Linux)
        # shellcheck source=shell/aliases_linux.sh
        source ~/.shell/aliases_linux.sh
        ;;
esac
