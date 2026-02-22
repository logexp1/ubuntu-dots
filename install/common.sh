#!/bin/bash

BASEDIR="$(dirname "$(dirname "$(realpath "${BASH_SOURCE[0]}")")")"

detect_os() {
    case "$(uname -s)" in
        Linux)
            if [[ -f /etc/os-release ]]; then
                . /etc/os-release
                case "$ID" in
                    ubuntu|debian) OS="linux-debian" ;;
                    arch|manjaro)  OS="linux-arch" ;;
                    fedora)        OS="linux-fedora" ;;
                    *)             OS="linux-unknown" ;;
                esac
            else
                OS="linux-unknown"
            fi
            ;;
        Darwin)
            OS="macos"
            ;;
        *)
            OS="unknown"
            ;;
    esac
    export OS
}

log_step() {
    local module="$1"
    shift
    echo -e "\033[1;34m[$module]\033[0m $*"
}

log_warn() {
    local module="$1"
    shift
    echo -e "\033[1;33m[$module]\033[0m $*" >&2
}

log_error() {
    local module="$1"
    shift
    echo -e "\033[1;31m[$module]\033[0m $*" >&2
}

require_cmd() {
    local cmd="$1"
    if ! command -v "$cmd" &>/dev/null; then
        log_error "common" "Required command '$cmd' not found. Please install it first."
        return 1
    fi
}

detect_os
