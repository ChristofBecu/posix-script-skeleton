#!/bin/sh
# Clone this POSIX script skeleton with a new name
# Called via: toolname --clone

set -e

# Color codes for output (optional, works in most terminals)
if [ -t 1 ]; then
    BOLD=$(printf '\033[1m')
    GREEN=$(printf '\033[0;32m')
    BLUE=$(printf '\033[0;34m')
    YELLOW=$(printf '\033[0;33m')
    RESET=$(printf '\033[0m')
else
    BOLD=""
    GREEN=""
    BLUE=""
    YELLOW=""
    RESET=""
fi

# Print functions
print_header() {
    printf '\n%s%s%s\n' "$BOLD$BLUE" "$1" "$RESET"
}

print_success() {
    printf '%s✓ %s%s\n' "$GREEN" "$1" "$RESET"
}

print_info() {
    printf '%s→ %s%s\n' "$YELLOW" "$1" "$RESET"
}

die() {
    printf 'Error: %s\n' "$1" >&2
    exit 1
}

# Validate tool name
validate_name() {
    _name="$1"
    
    # Check if empty
    if [ -z "$_name" ]; then
        return 1
    fi
    
    # Check if starts with dash or contains invalid characters
    case "$_name" in
        -*) return 1 ;;
        *[!A-Za-z0-9_-]*) return 1 ;;
    esac
    
    return 0
}

# Main clone function
clone_main() {
    # Check if running from source directory
    if [ "${INSTALL_MODE:-}" != "dev" ]; then
        die "--clone can only be used from the source directory"
    fi
    
    # BASEDIR is set by bootstrap in dev mode
    if [ -z "${BASEDIR:-}" ]; then
        die "Cannot determine source directory"
    fi
    
    SCRIPT_DIR="$BASEDIR"
    
    print_header "POSIX Script Skeleton Clone Tool"
    
    # Prompt for tool name
    printf '\n%sEnter the name for your new tool%s: ' "$BOLD" "$RESET"
    read -r NEW_TOOL_NAME
    
    # Validate tool name
    if ! validate_name "$NEW_TOOL_NAME"; then
        die "Invalid tool name. Use only alphanumeric characters, hyphens, and underscores. Cannot start with a dash."
    fi
    
    print_success "Tool name: $NEW_TOOL_NAME"
    
    # Prompt for target directory
    printf '\n%sEnter target directory%s (default: ../%s): ' "$BOLD" "$RESET" "$NEW_TOOL_NAME"
    read -r TARGET_DIR
    
    # Use default if empty
    if [ -z "$TARGET_DIR" ]; then
        TARGET_DIR="../$NEW_TOOL_NAME"
    fi
    
    # Expand ~ to $HOME (must check literal tilde character)
    case "$TARGET_DIR" in
        '~'/*) 
            # Remove leading ~/ and prepend $HOME
            TARGET_DIR="$HOME/${TARGET_DIR#'~/'}"
            ;;
        '~') 
            TARGET_DIR="$HOME"
            ;;
    esac
    
    # Make absolute if relative (only if not already absolute)
    case "$TARGET_DIR" in
        /*) 
            # Already absolute, do nothing
            ;;
        *) 
            # Relative path, make absolute
            TARGET_DIR="$(pwd)/$TARGET_DIR"
            ;;
    esac
    
    print_info "Target directory: $TARGET_DIR"
    
    # Check if target exists
    if [ -e "$TARGET_DIR" ]; then
        die "Target directory already exists: $TARGET_DIR"
    fi
    
    # Confirm
    printf '\n%sReady to create:%s\n' "$BOLD" "$RESET"
    printf '  Tool name: %s%s%s\n' "$GREEN" "$NEW_TOOL_NAME" "$RESET"
    printf '  Location:  %s%s%s\n' "$GREEN" "$TARGET_DIR" "$RESET"
    printf '\nProceed? [y/N]: '
    read -r CONFIRM
    
    case "$CONFIRM" in
        [Yy]|[Yy][Ee][Ss])
            ;;
        *)
            printf 'Cancelled.\n'
            exit 0
            ;;
    esac
    
    print_header "Creating new tool..."
    
    # Create target directory
    mkdir -p "$TARGET_DIR" || die "Cannot create directory: $TARGET_DIR"
    print_success "Created directory: $TARGET_DIR"
    
    # Copy skeleton files
    print_info "Copying skeleton files..."
    cp -r "$SCRIPT_DIR"/bin "$TARGET_DIR/" || die "Cannot copy bin/"
    cp -r "$SCRIPT_DIR"/lib "$TARGET_DIR/" || die "Cannot copy lib/"
    cp "$SCRIPT_DIR"/config "$TARGET_DIR/" || die "Cannot copy config"
    cp "$SCRIPT_DIR"/README "$TARGET_DIR/" || die "Cannot copy README"
    
    # Rename the binary
    mv "$TARGET_DIR/bin/$TOOL_NAME" "$TARGET_DIR/bin/$NEW_TOOL_NAME" || die "Cannot rename binary"
    print_success "Renamed binary to: bin/$NEW_TOOL_NAME"
    
    # Create empty data directory
    mkdir -p "$TARGET_DIR/data"
    print_success "Created data/ directory"
    
    # Update config file comment (optional)
    if command -v sed >/dev/null 2>&1; then
        sed -i.bak "s/# Configuration file for $TOOL_NAME/# Configuration file for $NEW_TOOL_NAME/" "$TARGET_DIR/config" 2>/dev/null && rm -f "$TARGET_DIR/config.bak"
    fi
    
    print_header "Success!"
    
    printf '\n%sYour new tool is ready at:%s\n' "$BOLD" "$RESET"
    printf '  %s%s%s\n\n' "$GREEN" "$TARGET_DIR" "$RESET"
    
    printf '%sNext steps:%s\n' "$BOLD" "$RESET"
    printf '  1. cd %s\n' "$TARGET_DIR"
    printf '  2. vi config                    # Configure lock and state scope\n'
    printf '  3. vi lib/core.sh               # Implement your tool logic\n'
    printf '  4. ./bin/%s --help         # Test your tool\n' "$NEW_TOOL_NAME"
    printf '  5. ./bin/%s --install      # Install when ready\n\n' "$NEW_TOOL_NAME"
    
    printf '%sDocumentation:%s\n' "$BOLD" "$RESET"
    printf '  See README for full documentation\n\n'
}
