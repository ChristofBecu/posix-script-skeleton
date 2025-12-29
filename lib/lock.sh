#!/bin/sh
# POSIX-safe locking module
# Supports: blocking, timeout, non-blocking

# Get default lockfile path
_get_lockfile_path() {
    if [ -n "$1" ]; then
        printf '%s' "$1"
    else
        _basename=$(basename "$0")
        printf '/tmp/%s.lock' "$_basename"
    fi
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
    ( set -C; > "$1" ) 2>/dev/null
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
    LOCKFILE=$(_get_lockfile_path "$1")
    TIMEOUT=${2:-0}      # 0 = block indefinitely
    NONBLOCK=${3:-0}     # 1 = do not wait, exit if locked

    _ensure_lock_dir "$LOCKFILE"
    _wait_for_lock "$LOCKFILE" "$TIMEOUT" "$NONBLOCK"

    # Ensure lock is removed on exit
    trap 'rm -f "$LOCKFILE"' EXIT INT TERM
}

# Release lock explicitly (optional)
lock_release() {
    LOCKFILE=$(_get_lockfile_path "$1")
    rm -f "$LOCKFILE"
    trap - EXIT INT TERM
}
