#!/bin/bash
set -e
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/common.sh"

run() {
    export PATH="$HOME/.local/bin:$PATH"
    require_cmd wal

    local wallpapers_src="$BASEDIR/assets/wallpapers"

    if [[ ! -d "$wallpapers_src" ]]; then
        log_error "wal" "Wallpapers directory not found at $wallpapers_src"
        return 1
    fi

    # Symlink the whole wallpapers directory
    [[ -d "$HOME/.wallpapers" && ! -L "$HOME/.wallpapers" ]] && rm -rf "$HOME/.wallpapers"
    ln -sfn "$wallpapers_src" "$HOME/.wallpapers"

    # Pick a random wallpaper excluding lock-wallpaper.png
    local wallpaper
    wallpaper=$(find -L "$HOME/.wallpapers" -type f ! -name 'lock-wallpaper.png' | shuf -n 1)

    log_step "wal" "Generating color scheme from $wallpaper..."
    wal -i "$wallpaper" -s -t
    log_step "wal" "Done."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    run
fi
