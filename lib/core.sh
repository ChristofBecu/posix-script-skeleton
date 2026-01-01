#!/bin/sh
# Core application logic

main() {
    parse_args "$@"
    load_state
    run
    save_state
}

parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --install)
                # Only available in cloned dev versions (not original skeleton, not installed)
                if [ "${INSTALL_MODE:-}" != "dev" ]; then
                    error "--install can only be used from the source directory"
                elif [ "${IS_SKELETON_ORIGIN:-false}" = "true" ]; then
                    error "--install is not available in the original skeleton. Use --clone first."
                else
                    . "$BASEDIR/lib/install.sh"
                    install_main
                    exit 0
                fi
                ;;
            --uninstall)
                # Only available in installed versions (user or system mode)
                if [ "${INSTALL_MODE:-}" = "dev" ]; then
                    error "--uninstall can only be used from an installed version"
                else
                    . "$LIB_DIR/install.sh"
                    uninstall_main
                    exit 0
                fi
                ;;
            --clone)
                # Only available in original skeleton in dev mode
                if [ "${INSTALL_MODE:-}" != "dev" ]; then
                    error "--clone can only be used from the source directory"
                elif [ "${IS_SKELETON_ORIGIN:-false}" != "true" ]; then
                    error "--clone is only available in the original skeleton"
                else
                    . "$BASEDIR/lib/clone.sh"
                    clone_main
                    exit 0
                fi
                ;;
            -h|--help)
                usage
                ;;
            -*)
                error "Unknown option: $1"
                ;;
            *)
                INPUT=$1
                ;;
        esac
        shift
    done
}

run() {
    COUNT=$(expr "$COUNT" + 1)
    info "Run count: $COUNT"
    sleep 2
}
