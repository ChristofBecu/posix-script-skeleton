#!/bin/sh
# State persistence management

# State scope follows lock scope by default
# Set STATE_SCOPE to control state file location:
#   "user"   - Per-user state files (default)
#   "system" - System-wide state file
STATE_SCOPE="${STATE_SCOPE:-${LOCK_SCOPE:-system}}"

# Get state file path
get_state_file() {
    _basedir="${BASEDIR:-.}/data"
    _basename=$(basename "$0")
    
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