#!/bin/sh
# State persistence management

# State scope configuration is set via config file and bootstrap
# STATE_SCOPE values:
#   "user"   - Per-user state files
#   "system" - System-wide state file

# Get state file path
get_state_file() {
    _basename=$(basename "$0")
    
    # Determine base directory based on install mode
    case "${INSTALL_MODE:-dev}" in
        dev)
            _basedir="${BASEDIR:-.}/data"
            ;;
        user)
            _basedir="$HOME/.local/state/$TOOL_NAME"
            ;;
        system)
            _basedir="/var/tmp/$TOOL_NAME"
            ;;
        *)
            _basedir="${BASEDIR:-.}/data"
            ;;
    esac
    
    case "$STATE_SCOPE" in
        system)
            printf '%s/%s.state' "$_basedir" "$_basename"
            ;;
        user|*)
            _uid=$(id -u)
            printf '%s/%s.%s.state' "$_basedir" "$_basename" "$_uid"
            ;;
    esac
}

STATE_FILE=$(get_state_file)

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
    _ensure_state_dir
    {
        printf 'COUNT=%s\n' "$COUNT"
    } > "$STATE_FILE"
}
    

_ensure_state_dir() {
    _statedir=$(dirname "$STATE_FILE")
    if [ ! -d "$_statedir" ]; then
        mkdir -p "$_statedir" || {
            error "Failed to create state directory: $_statedir" >&2
            exit 1
        }
    fi
}