#!/bin/bash
set -e

if [[ $EUID -eq 0 ]]; then
    echo "Please run this script as a regular user, not root."
    exit 1
fi

INSTALL_DIR="$(dirname "$(realpath "$0")")/install"
source "$INSTALL_DIR/common.sh"

MODULES=(git emacs doom systemd browserpass hyprpm stow)

usage() {
    echo "Usage: $(basename "$0") <module> [module...]"
    echo ""
    echo "Available modules:"
    for mod in "${MODULES[@]}"; do
        echo "  $mod"
    done
    echo ""
    echo "Examples:"
    echo "  $(basename "$0") font git stow"
    echo "  $(basename "$0") ${MODULES[*]}"
}

is_valid_module() {
    local name="$1"
    for mod in "${MODULES[@]}"; do
        [[ "$mod" == "$name" ]] && return 0
    done
    return 1
}

if [[ $# -eq 0 ]]; then
    usage
    exit 0
fi

for mod in "$@"; do
    if ! is_valid_module "$mod"; then
        log_error "install" "Unknown module: $mod"
        echo ""
        usage
        exit 1
    fi
done

for mod in "$@"; do
    echo ""
    source "$INSTALL_DIR/${mod}.sh"
    run
done

echo ""
log_step "install" "All done!"
