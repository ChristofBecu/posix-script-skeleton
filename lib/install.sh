#!/bin/sh
# Installation library
# Sourced when --install or --uninstall is used

set -e

# Path constants (use TOOL_NAME from bootstrap)
SYSTEM_BIN="/bin/$TOOL_NAME"
SYSTEM_LIB_DIR="/etc/$TOOL_NAME/lib"
SYSTEM_CONFIG="/etc/$TOOL_NAME/config"
SYSTEM_STATE_DIR="/var/tmp/$TOOL_NAME"

USER_BIN="$HOME/.local/bin/$TOOL_NAME"
USER_LIB_DIR="$HOME/.local/lib/$TOOL_NAME"
USER_CONFIG="$HOME/.${TOOL_NAME}rc"
USER_STATE_DIR="$HOME/.local/state/$TOOL_NAME"

die() {
    printf '%s\n' "Error: $1" >&2
    exit 1
}

# Get source directory (where the script is running from)
get_source_dir() {
    _script_path="$0"
    _script_dir="$(dirname "$_script_path")"
    _source_dir="$(cd "$_script_dir/.." && pwd)"
    echo "$_source_dir"
}

# Read config scope from source config file
read_config_scope() {
    _src_dir="$(get_source_dir)"
    _config="$_src_dir/config"
    
    if [ ! -f "$_config" ]; then
        echo "user"
        return
    fi
    
    _lock_scope=$(grep '^LOCK_SCOPE=' "$_config" 2>/dev/null | cut -d'"' -f2 || echo "user")
    _state_scope=$(grep '^STATE_SCOPE=' "$_config" 2>/dev/null | cut -d'"' -f2 || echo "user")
    
    if [ "$_lock_scope" = "system" ] || [ "$_state_scope" = "system" ]; then
        echo "system"
    else
        echo "user"
    fi
}

# Detect current installation mode
detect_install_mode() {
    if [ -f "$USER_CONFIG" ]; then
        echo "user"
    elif [ -f "$SYSTEM_CONFIG" ]; then
        echo "system"
    else
        echo "none"
    fi
}

# Check root privileges
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        die "$1"
    fi
}

# Create directories for installation
create_dirs() {
    _mode="$1"
    if [ "$_mode" = "system" ]; then
        mkdir -p "$(dirname "$SYSTEM_BIN")" || die "Cannot create $SYSTEM_BIN directory"
        mkdir -p "$SYSTEM_LIB_DIR" || die "Cannot create $SYSTEM_LIB_DIR"
        mkdir -p "$(dirname "$SYSTEM_CONFIG")" || die "Cannot create system config directory"
        mkdir -p "$SYSTEM_STATE_DIR" || die "Cannot create $SYSTEM_STATE_DIR"
    else
        mkdir -p "$(dirname "$USER_BIN")" || die "Cannot create $USER_BIN directory"
        mkdir -p "$USER_LIB_DIR" || die "Cannot create $USER_LIB_DIR"
        mkdir -p "$USER_STATE_DIR" || die "Cannot create $USER_STATE_DIR"
    fi
}

# Copy files to installation location
copy_files() {
    _mode="$1"
    _src_dir="$(get_source_dir)"
    
    if [ "$_mode" = "system" ]; then
        cp "$_src_dir/bin/$TOOL_NAME" "$SYSTEM_BIN" || die "Cannot copy binary"
        chmod +x "$SYSTEM_BIN"
        cp "$_src_dir"/lib/*.sh "$SYSTEM_LIB_DIR/" || die "Cannot copy libraries"
        cp "$_src_dir/config" "$SYSTEM_CONFIG" || die "Cannot copy config"
    else
        cp "$_src_dir/bin/$TOOL_NAME" "$USER_BIN" || die "Cannot copy binary"
        chmod +x "$USER_BIN"
        cp "$_src_dir"/lib/*.sh "$USER_LIB_DIR/" || die "Cannot copy libraries"
        cp "$_src_dir/config" "$USER_CONFIG" || die "Cannot copy config"
    fi
}

# Remove installed files
remove_files() {
    _mode="$1"
    if [ "$_mode" = "system" ]; then
        rm -f "$SYSTEM_BIN"
        rm -rf "$(dirname "$SYSTEM_CONFIG")"
    else
        rm -f "$USER_BIN"
        rm -f "$USER_CONFIG"
        rm -rf "$USER_LIB_DIR"
    fi
}

# Main install function
install_main() {
    _current=$(detect_install_mode)
    
    if [ "$_current" != "none" ]; then
        die "Already installed in $_current mode. Uninstall first with: $TOOL_NAME --uninstall"
    fi
    
    _scope=$(read_config_scope)
    
    printf 'Installing %s (%s mode)...\n' "$TOOL_NAME" "$_scope"
    
    if [ "$_scope" = "system" ]; then
        check_root "System-wide installation requires root privileges. Run with sudo."
        create_dirs "system"
        copy_files "system"
        printf 'Installation complete!\n'
        printf '  Binary: %s\n' "$SYSTEM_BIN"
        printf '  Config: %s\n' "$SYSTEM_CONFIG"
        printf '  Libraries: %s\n' "$SYSTEM_LIB_DIR"
        printf '  State directory: %s\n' "$SYSTEM_STATE_DIR"
    else
        create_dirs "user"
        copy_files "user"
        printf 'Installation complete!\n'
        printf '  Binary: %s\n' "$USER_BIN"
        printf '  Config: %s\n' "$USER_CONFIG"
        printf '  Libraries: %s\n' "$USER_LIB_DIR"
        printf '  State directory: %s\n' "$USER_STATE_DIR"
        printf '\nNote: Ensure %s is in your PATH\n' "$HOME/.local/bin"
    fi
}

# Main uninstall function
uninstall_main() {
    _current=$(detect_install_mode)
    
    if [ "$_current" = "none" ]; then
        die "$TOOL_NAME is not installed"
    fi
    
    printf 'Uninstalling %s (%s mode)...\n' "$TOOL_NAME" "$_current"
    
    if [ "$_current" = "system" ]; then
        check_root "System-wide uninstallation requires root privileges. Run with sudo."
        remove_files "system"
        printf 'Uninstallation complete!\n'
        printf 'Removed: %s\n' "$SYSTEM_BIN"
        printf 'Note: State directory %s was preserved\n' "$SYSTEM_STATE_DIR"
        printf '      Remove manually if needed: sudo rm -rf %s\n' "$SYSTEM_STATE_DIR"
    else
        remove_files "user"
        printf 'Uninstallation complete!\n'
        printf 'Removed: %s\n' "$USER_BIN"
        printf 'Note: State directory %s was preserved\n' "$USER_STATE_DIR"
        printf '      Remove manually if needed: rm -rf %s\n' "$USER_STATE_DIR"
    fi
}
