# shellcheck shell=bash

inotifyrun() {
    if [ -z "$1" ]; then
        echo "usage: $0 <ext> [cmd]"
        return 1
    fi
    local ext="$1"
    shift 1
    if [ -z "$1" ]; then
        return 1
    fi
    while true; do
        inotifywait -e modify -q ./**/*."$ext"
        if [ $? -eq 1 ]; then
            echo "$(date) Running $*"
            "$@"
        fi
    done
}
