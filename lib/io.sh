#!/bin/sh
# Input/output utility functions

usage() {
    _tool="${TOOL_NAME:-toolname}"
    _mode="${INSTALL_MODE:-dev}"
    _is_origin="${IS_SKELETON_ORIGIN:-false}"
    
    cat << EOF
Usage: $_tool [options] [args]

Options:
    -h, --help         Show this help message
EOF

    # Show available commands based on context
    if [ "$_mode" = "dev" ] && [ "$_is_origin" = "true" ]; then
        # Original skeleton in dev mode
        cat << EOF
    --clone            Clone this skeleton with a new name (interactive)

Development Mode (Original Skeleton):
    This is the original posix-script-skeleton. Use --clone to create
    a new tool based on this skeleton.
EOF
    elif [ "$_mode" = "dev" ]; then
        # Cloned version in dev mode
        cat << EOF
    --install          Install the tool (system-wide or user, based on config)

Development Mode:
    Running from source directory. Use --install to install this tool.
EOF
    else
        # Installed version (user or system mode)
        cat << EOF
    --uninstall        Uninstall the tool

Installed Mode ($_mode):
    This is an installed version. Use --uninstall to remove it.
EOF
    fi

    cat << EOF

Configuration:
    Edit the 'config' file to customize lock scope and behavior.
    All configuration is done via the config file only.

    LOCK_SCOPE:    "user" (per-user) or "system" (system-wide)
    STATE_SCOPE:   "user" (per-user) or "system" (system-wide)
    LOCK_TIMEOUT:  Timeout in seconds (0 = wait indefinitely)
    LOCK_NONBLOCK: 1 = exit if locked, 0 = wait for lock
EOF

    # Show relevant examples
    if [ "$_mode" = "dev" ] && [ "$_is_origin" = "true" ]; then
        cat << EOF

Examples:
    $_tool --clone                    # Create a new tool from skeleton
    $_tool --help                     # Show this help
EOF
    elif [ "$_mode" = "dev" ]; then
        cat << EOF

Examples:
    $_tool --help                     # Show this help
    $_tool --install                  # Install this tool
EOF
    else
        cat << EOF

Examples:
    $_tool --help                     # Show this help
    $_tool --uninstall                # Uninstall this tool
EOF
    fi
    
    exit 1
}

error() {
    printf '%s\n' "Error: $1" >&2
    exit 1
}

info() {
    printf '%s\n' "Info: $1"
}