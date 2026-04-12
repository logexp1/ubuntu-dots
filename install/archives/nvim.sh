#!/bin/bash
set -e
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/common.sh"

INSTALL_PREFIX="/usr/local"
NVIM_TAG="stable"

fetch_tarball() {
    local arch tarball url
    arch="$(uname -m)"
    tarball="nvim-linux-${arch}.tar.gz"
    url="https://github.com/neovim/neovim/releases/download/${NVIM_TAG}/${tarball}"
    NVIM_TMP="$(mktemp -d)"

    log_step "nvim" "Downloading $url..." >&2
    curl -fsSL "$url" -o "$NVIM_TMP/$tarball" >&2

    echo "$NVIM_TMP/$tarball"
}

run() {
    log_step "nvim" "Installing Neovim from GitHub releases (tag: $NVIM_TAG)..."
    require_cmd curl
    require_cmd tar

    local archive
    archive="$(fetch_tarball)"
    local tmp
    tmp="$(dirname "$archive")"

    trap 'rm -rf "$tmp"' EXIT

    log_step "nvim" "Extracting to $INSTALL_PREFIX..."
    sudo tar -C "$INSTALL_PREFIX" --strip-components=1 -xzf "$archive"

    log_step "nvim" "Installed: $(nvim --version | head -1)"
}

uninstall() {
    log_step "nvim" "Uninstalling Neovim (tag: $NVIM_TAG)..."
    require_cmd curl
    require_cmd tar

    local archive
    archive="$(fetch_tarball)"
    local tmp
    tmp="$(dirname "$archive")"

    trap 'rm -rf "$tmp"' EXIT

    log_step "nvim" "Removing files installed to $INSTALL_PREFIX..."
    tar -tf "$archive" | sed 's|^[^/]*/||' | grep -v '^$' | while read -r f; do
        local target="$INSTALL_PREFIX/$f"
        if [[ -f "$target" || -L "$target" ]]; then
            sudo rm -f "$target"
        fi
    done

    # remove leftover empty dirs
    sudo rmdir --ignore-fail-on-non-empty \
        "$INSTALL_PREFIX/lib/nvim" \
        "$INSTALL_PREFIX/share/nvim" \
        "$INSTALL_PREFIX/share/man/man1" \
        2>/dev/null || true

    log_step "nvim" "Done."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    case "${1:-}" in
        --uninstall|-D) uninstall ;;
        *)              run ;;
    esac
fi
