# shellcheck shell=bash

export AWKPATH="$HOME/.awk:$AWKPATH"
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.scripts:$PATH"

# Homebrew
if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# shellcheck source=/dev/null
[ -f ~/.cargo/env ] && source ~/.cargo/env
