#!/bin/sh
# Input/output utility functions

usage() {
    cat << EOF
Usage: toolname [options] [args]

Options:
    -h, --help         Show this help message

Configuration:
    Edit the 'config' file to customize lock scope and behavior.
    Environment variables can override config file settings.
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