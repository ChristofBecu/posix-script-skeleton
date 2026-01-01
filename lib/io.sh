#!/bin/sh
# Input/output utility functions

usage() {
    cat << EOF
Usage: ${TOOL_NAME:-toolname} [options] [args]

Options:
    -h, --help         Show this help message
    --install          Install the tool (system-wide or user, based on config)
    --uninstall        Uninstall the tool
    --clone            Clone this skeleton with a new name (interactive)

Development Commands (only available when running from source):
    The --install, --uninstall, and --clone commands are only available
    when running from the source directory.

Configuration:
    Edit the 'config' file to customize lock scope and behavior.
    Environment variables can override config file settings.

    LOCK_SCOPE:    "user" (per-user) or "system" (system-wide)
    STATE_SCOPE:   "user" (per-user) or "system" (system-wide)
    LOCK_TIMEOUT:  Timeout in seconds (0 = wait indefinitely)
    LOCK_NONBLOCK: 1 = exit if locked, 0 = wait for lock

Examples:
    ${TOOL_NAME:-toolname} --help
    ${TOOL_NAME:-toolname} --install
    ${TOOL_NAME:-toolname} --clone
EOF
    exit 1
}

error() {
    printf '%s\n' "Error: $1" >&2
    exit 1
}

info() {
    printf '%s\n' "Info: $1"
}