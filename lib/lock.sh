#!/bin/sh
# POSIX-safe locking module
# Supports: blocking, timeout, non-blocking

# Lock scope configuration
# Set LOCK_SCOPE to control locking behavior:
#   "user"   - Per-user locking (default, isolated by UID)
#   "system" - System-wide locking (single instance across all users)
LOCK_SCOPE="${LOCK_SCOPE:-system}"

# Get default lockfile path
_get_lockfile_path() {
    if [ -n "$1" ]; then
        printf '%s' "$1"
        return
    fi
    
    _basename=$(basename "$0")
    
    case "$LOCK_SCOPE" in
        system)
            printf '/tmp/%s.lock' "$_basename"
            ;;
        user|*)
            _uid=$(id -u)
            printf '/tmp/%s.%s.lock' "$_basename" "$_uid"
            ;;
    esac
}

# Ensure lock directory exists
_ensure_lock_dir() {
    LOCKDIR=$(dirname "$1")
    if [ ! -d "$LOCKDIR" ]; then
        mkdir -p "$LOCKDIR" || {
            error "Failed to create lock directory: $LOCKDIR" >&2
            exit 1
        }
    fi
}

# Try to acquire lock (non-blocking)
_try_lock() {
    if ( set -C; printf '%s\n' "$$" > "$1" ) 2>/dev/null; then
        return 0
    fi
    return 1
}

# Wait for lock with timeout
_wait_for_lock() {
    _lockfile="$1"
    _timeout="$2"
    _nonblock="$3"
    _waited=0

    while ! _try_lock "$_lockfile"; do
        if [ "$_nonblock" -eq 1 ]; then
            error "Another instance is running. Exiting." >&2
            exit 1
        fi

        if [ "$_timeout" -gt 0 ] && [ "$_waited" -ge "$_timeout" ]; then
            error "Timeout waiting for lock. Exiting." >&2
            exit 1
        fi

        sleep 1
        _waited=$(expr "$_waited" + 1)
    done
}

# Acquire lock (blocking by default)
# Usage:
#   lock_acquire "/tmp/tool.lock" [timeout_seconds] [nonblocking]
lock_acquire() {
    LOCKFILE=$(_get_lockfile_path "${1:-}")
    TIMEOUT=${2:-0}      # 0 = block indefinitely
    NONBLOCK=${3:-0}     # 1 = do not wait, exit if locked

    _ensure_lock_dir "$LOCKFILE"
    _wait_for_lock "$LOCKFILE" "$TIMEOUT" "$NONBLOCK"

    # Ensure lock is removed on exit
    trap 'rm -f "$LOCKFILE"' EXIT INT TERM
}

# Release lock explicitly (optional)
lock_release() {
    LOCKFILE=$(_get_lockfile_path "${1:-}")
    
    # Verify we own the lock
    if [ -f "$LOCKFILE" ]; then
        _lock_pid=$(cat "$LOCKFILE" 2>/dev/null || printf '')
        if [ -n "$_lock_pid" ] && [ "$_lock_pid" != "$$" ]; then
            error "Lock owned by PID $_lock_pid, cannot release" >&2
            return 1
        fi
    fi
    
    rm -f "$LOCKFILE"
    trap - EXIT INT TERM
}
