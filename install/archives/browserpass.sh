#!/bin/bash
set -e
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/common.sh"

run() {
    log_step "browserpass" "Installing browserpass-native..."
    require_cmd curl
    require_cmd jq
    require_cmd gpg
    require_cmd make

    case "$OS" in
        linux-*)  bin_suffix="linux64" ;;
        macos)    bin_suffix="darwin64" ;;
        *)
            log_error "browserpass" "Unsupported OS: $OS"
            return 1
            ;;
    esac

    log_step "browserpass" "Importing maintainer PGP key..."
    curl -s https://maximbaz.com/pgp_keys.asc | gpg --import

    local build_dir="$HOME/build"
    mkdir -p "$build_dir"

    log_step "browserpass" "Fetching latest release info..."
    local latest_tag
    latest_tag=$(curl -s https://api.github.com/repos/browserpass/browserpass-native/releases | jq -r '.[0].name')
    local tarball_url
    tarball_url=$(curl -s https://api.github.com/repos/browserpass/browserpass-native/releases | jq -r '.[0].tarball_url')
    local file_name="browserpass-native-${latest_tag}.tar.gz"

    # Clean up previous builds
    for dir in "$build_dir"/*browserpass-native-*/; do
        [[ -d "$dir" ]] && rm -rf "$dir"
    done

    log_step "browserpass" "Downloading $file_name..."
    if ! curl -L "$tarball_url" -o "$build_dir/$file_name"; then
        log_error "browserpass" "Failed to download browserpass release."
        return 1
    fi

    log_step "browserpass" "Building..."
    local extracted_dir
    extracted_dir=$(tar -tf "$build_dir/$file_name" | head -1 | cut -d/ -f1)
    tar -xzf "$build_dir/$file_name" -C "$build_dir"

    make -C "$build_dir/$extracted_dir" "browserpass-${bin_suffix}"
    make -C "$build_dir/$extracted_dir" "BIN=browserpass-${bin_suffix}" configure

    log_step "browserpass" "Installing (requires sudo)..."
    sudo make -C "$build_dir/$extracted_dir" "BIN=browserpass-${bin_suffix}" install

    log_step "browserpass" "Configuring browser hosts..."
    local browserpass_lib
    case "$OS" in
        linux-*)  browserpass_lib="/usr/lib/browserpass" ;;
        macos)    browserpass_lib="/usr/local/lib/browserpass" ;;
    esac
    make -C "$browserpass_lib" hosts-firefox-user
    make -C "$browserpass_lib" hosts-brave-user

    log_step "browserpass" "Done."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    run
fi
