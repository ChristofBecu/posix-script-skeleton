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
            --install|--uninstall)
                # Check if running from source directory (dev mode)
                if [ "${INSTALL_MODE:-}" = "dev" ]; then
                    . "$BASEDIR/lib/install.sh"
                    case "$1" in
                        --install)   install_main ;;
                        --uninstall) uninstall_main ;;
                    esac
                    exit 0
                else
                    error "$1 can only be used from the source directory"
                fi
                ;;
            --clone)
                # Check if running from source directory (dev mode)
                if [ "${INSTALL_MODE:-}" = "dev" ]; then
                    . "$BASEDIR/lib/clone.sh"
                    clone_main
                    exit 0
                else
                    error "--clone can only be used from the source directory"
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
