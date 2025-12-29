#!/bin/sh
# State persistence management

STATE_FILE=${STATE_FILE:-"$BASEDIR/data/toolname.state"}

load_state() {
    if [ -f "$STATE_FILE" ]; then
        . "$STATE_FILE"
    else
        init_state
    fi
}

init_state() {
    COUNT=0
}

save_state() {
    {
        printf 'COUNT=%s\n' "$COUNT"
    } > "$STATE_FILE"
}