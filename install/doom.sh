#!/bin/bash
set -e
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/common.sh"

run() {
    local doom_dir="$HOME/.config/emacs"
    local doom_config="$HOME/.config/doom"

    log_step "doom" "Symlinking org directory..."
    [[ -e "$HOME/.org" ]] || ln -sn "$HOME/OneDrive/org" "$HOME/.org"

    log_step "doom" "Cloning Doom Emacs..."
    require_cmd git
    require_cmd emacs

    if [[ -d "$doom_dir" ]]; then
        log_step "doom" "Doom already installed at $doom_dir, syncing..."
        "$doom_dir/bin/doom" sync
        return 0
    fi

    git clone --depth 1 https://github.com/doomemacs/doomemacs "$doom_dir"

    log_step "doom" "Running doom install..."
    "$doom_dir/bin/doom" install

    log_step "doom" "Syncing Doom Emacs..."
    "$doom_dir/bin/doom" sync

    log_step "doom" "Building pdf-tools server..."
    local pdf_server
    pdf_server=$(find "$HOME/.config/emacs/.local/straight" -path "*/pdf-tools/build/server" -type d 2>/dev/null | head -1)
    if [[ -n "$pdf_server" ]]; then
        autoreconf -i "$pdf_server"
        "$pdf_server/autobuild" -i "$(dirname "$(dirname "$pdf_server")")"
    else
        log_warn "doom" "pdf-tools server directory not found, skipping build"
    fi

	log_step "doom" "Done."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    run
fi
