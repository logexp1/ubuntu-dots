#!/bin/bash
set -e
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/common.sh"

ya_pkg_add() {
    local pkg="$1"
    local name="${pkg##*:}"
    local pkg_toml="${XDG_CONFIG_HOME:-$HOME/.config}/yazi/package.toml"
    if grep -q "$name" "$pkg_toml" 2>/dev/null; then
        log_step "yazi" "  $name: already installed"
    else
        ya pkg add "$pkg"
    fi
}

run() {
    log_step "yazi" "Installing yazi plugins..."
    require_cmd ya

    ya_pkg_add yazi-rs/plugins:smart-enter
    ya_pkg_add yazi-rs/plugins:full-border
    ya_pkg_add yazi-rs/plugins:git
    ya_pkg_add yazi-rs/plugins:chmod
    ya pkg install

    log_step "yazi" "Setting xdg mime defaults..."
    xdg-mime default org.pwmt.zathura.desktop application/pdf
    xdg-mime default imv.desktop image/png
    xdg-mime default imv.desktop image/jpeg
    xdg-mime default imv.desktop image/gif
    xdg-mime default imv.desktop image/webp
    xdg-mime default imv.desktop image/svg+xml

    log_step "yazi" "Done."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    run
fi
