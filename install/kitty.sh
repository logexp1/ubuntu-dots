#!/bin/bash
set -e
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/common.sh"

KITTY_APP="$HOME/.local/kitty.app"

run() {
    log_step "kitty" "Installing Kitty terminal..."
    require_cmd curl

    curl -fsSL https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n

    log_step "kitty" "Creating symlinks in ~/.local/bin..."
    mkdir -p "$HOME/.local/bin"
    ln -sf "$KITTY_APP/bin/kitty" "$HOME/.local/bin/kitty"
    ln -sf "$KITTY_APP/bin/kitten" "$HOME/.local/bin/kitten"

    log_step "kitty" "Installing desktop entry..."
    mkdir -p "$HOME/.local/share/applications"
    cp "$KITTY_APP/share/applications/kitty.desktop" "$HOME/.local/share/applications/"
    sed -i "s|Icon=kitty|Icon=$KITTY_APP/share/icons/hicolor/256x256/apps/kitty.png|g" "$HOME/.local/share/applications/kitty.desktop"
    sed -i "s|Exec=kitty|Exec=$KITTY_APP/bin/kitty|g" "$HOME/.local/share/applications/kitty.desktop"
    update-desktop-database "$HOME/.local/share/applications"

    log_step "kitty" "Installed: $("$KITTY_APP/bin/kitty" --version)"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    run
fi
