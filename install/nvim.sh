#!/bin/bash
set -e
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/common.sh"

INSTALL_PREFIX="/usr/local"
NVIM_TAG="stable"

run() {
    log_step "nvim" "Installing Neovim from GitHub releases (tag: $NVIM_TAG)..."
    require_cmd curl
    require_cmd tar

    local arch
    arch="$(uname -m)"  # x86_64 or aarch64

    local tarball="nvim-linux-${arch}.tar.gz"
    local url="https://github.com/neovim/neovim/releases/download/${NVIM_TAG}/${tarball}"
    local tmp
    tmp="$(mktemp -d)"

    trap 'rm -rf "$tmp"' EXIT

    log_step "nvim" "Downloading $url..."
    curl -fsSL "$url" -o "$tmp/$tarball"

    log_step "nvim" "Extracting to $INSTALL_PREFIX..."
    sudo tar -C "$INSTALL_PREFIX" --strip-components=1 -xzf "$tmp/$tarball"

    log_step "nvim" "Installed: $(nvim --version | head -1)"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    run
fi
