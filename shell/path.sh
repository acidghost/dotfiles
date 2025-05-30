# shellcheck shell=bash

export AWKPATH="$HOME/.awk:$AWKPATH"

# Homebrew
if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# shellcheck source=/dev/null
[ -f ~/.cargo/env ] && source ~/.cargo/env

# leave these as last in order to come on top
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.scripts:$PATH"
