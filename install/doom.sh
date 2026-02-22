#!/bin/bash
set -e
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/common.sh"

run() {
    local doom_dir="$HOME/.config/emacs"
    local doom_config="$HOME/.config/doom"

    log_step "doom" "Cloning Doom Emacs..."
    require_cmd git
    require_cmd emacs

    if [[ -d "$doom_dir" ]]; then
        log_step "doom" "$doom_dir already exists, upgrading..."
        "$doom_dir/bin/doom" upgrade
    else
        git clone --depth 1 https://github.com/doomemacs/doomemacs "$doom_dir"
    fi

    log_step "doom" "Running doom install..."
    "$doom_dir/bin/doom" install

    log_step "doom" "Syncing Doom Emacs..."
    "$doom_dir/bin/doom" sync

    log_step "doom" "Done."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    run
fi
