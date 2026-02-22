#!/bin/bash
set -e
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/common.sh"

run() {
    log_step "systemd" "Enabling user systemd services..."

    if [[ "$OS" == macos || "$OS" == unknown ]]; then
        log_warn "systemd" "systemd not available on $OS, skipping."
        return 0
    fi

    require_cmd systemctl

    systemctl --user enable onedrive
    log_step "systemd" "Done."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    run
fi
