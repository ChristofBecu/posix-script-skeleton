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
