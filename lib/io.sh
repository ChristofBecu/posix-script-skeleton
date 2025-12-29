#!/bin/sh
# Input/output utility functions

usage() {
    printf '%s\n' "Usage: toolname [options] [args]"
    exit 1
}

error() {
    printf '%s\n' "Error: $1" >&2
    exit 1
}

info() {
    printf '%s\n' "Info: $1"
}