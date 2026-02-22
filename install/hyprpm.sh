#!/bin/bash
set -e
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/common.sh"

run() {
    log_step "hyprpm" "Setting up Hyprland plugins..."

    if ! command -v hyprpm &>/dev/null; then
        log_warn "hyprpm" "hyprpm not found, skipping."
        return 0
    fi

    hyprpm update
    hyprpm add https://github.com/hyprwm/hyprland-plugins
	hyprpm reload

	log_step "hyprpm" "Done."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    run
fi
