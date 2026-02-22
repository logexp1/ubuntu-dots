#!/bin/bash
set -e
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/common.sh"

run() {
    log_step "zsh" "Setting zsh as default shell..."
    require_cmd zsh

    local zsh_path
    zsh_path="$(which zsh)"

    if [[ "$SHELL" == *zsh ]]; then
        log_step "zsh" "Default shell is already zsh ($SHELL). Skipping."
        return 0
    fi

    log_step "zsh" "Changing default shell to $zsh_path (you may be prompted for your password)..."
    chsh -s "$zsh_path"

    log_step "zsh" "Done. Log out and back in for the change to take effect."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    run
fi
