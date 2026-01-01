#!/bin/sh
# Environment detection and initialization
# Sets up paths and variables for dev/user/system install modes

# Initialize bootstrap environment
bootstrap_init() {
    _basedir="${1:-}"
    
    # Detect tool name from script name
    TOOL_NAME=$(basename "$0")
    export TOOL_NAME
    
    # Determine install mode and paths
    if [ -n "$_basedir" ] && [ -f "$_basedir/config" ]; then
        # Development mode: running from source directory
        INSTALL_MODE="dev"
        BASEDIR="$_basedir"
        LIB_DIR="$BASEDIR/lib"
        CONFIG_FILE="$BASEDIR/config"
        
        # Load config for dev mode
        if [ -f "$CONFIG_FILE" ]; then
            . "$CONFIG_FILE"
        fi
    elif [ -f "$HOME/.local/lib/$TOOL_NAME/bootstrap.sh" ]; then
        # User installation mode
        INSTALL_MODE="user"
        BASEDIR="$HOME/.local/lib/$TOOL_NAME"
        LIB_DIR="$BASEDIR"
        CONFIG_FILE="$HOME/.${TOOL_NAME}rc"
        
        # Load user config
        if [ -f "$CONFIG_FILE" ]; then
            . "$CONFIG_FILE"
        fi
    elif [ -f "/etc/$TOOL_NAME/lib/bootstrap.sh" ]; then
        # System installation mode
        INSTALL_MODE="system"
        BASEDIR="/etc/$TOOL_NAME"
        LIB_DIR="$BASEDIR/lib"
        CONFIG_FILE="/etc/$TOOL_NAME/config"
        
        # Load system config
        if [ -f "$CONFIG_FILE" ]; then
            . "$CONFIG_FILE"
        fi
    else
        printf 'Error: Cannot determine installation mode\n' >&2
        exit 1
    fi
    
    # Export environment variables
    export INSTALL_MODE
    export BASEDIR
    export LIB_DIR
    export CONFIG_FILE
    
    # Set defaults if not configured
    LOCK_SCOPE="${LOCK_SCOPE:-system}"
    STATE_SCOPE="${STATE_SCOPE:-${LOCK_SCOPE}}"
    LOCK_TIMEOUT="${LOCK_TIMEOUT:-0}"
    LOCK_NONBLOCK="${LOCK_NONBLOCK:-0}"
    
    export LOCK_SCOPE
    export STATE_SCOPE
    export LOCK_TIMEOUT
    export LOCK_NONBLOCK
}
