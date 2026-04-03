#!/bin/bash

set -e
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/common.sh"

run() {
    if [[ "$OS" != "linux-debian" ]]; then
        log_error "firefox-deb" "This script is only for Debian/Ubuntu systems."
        return 1
    fi

    require_cmd wget

    log_step "firefox-deb" "Adding Mozilla APT signing key..."
    sudo install -d -m 0755 /etc/apt/keyrings
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- \
        | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null

    log_step "firefox-deb" "Adding Mozilla APT repository..."
    echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" \
        | sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null

    log_step "firefox-deb" "Pinning Mozilla repo to prefer .deb over snap..."
    printf 'Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000\n' \
        | sudo tee /etc/apt/preferences.d/mozilla > /dev/null

    log_step "firefox-deb" "Removing snap Firefox..."
    if snap list firefox &>/dev/null; then
        sudo snap remove firefox
    else
        log_step "firefox-deb" "Snap Firefox not installed, skipping."
    fi

    log_step "firefox-deb" "Installing Firefox from Mozilla APT repo..."
    sudo apt update
    sudo apt install -y --allow-downgrades firefox

    log_step "firefox-deb" "Done. Firefox is now installed as a .deb package."
    log_step "firefox-deb" "Native messaging hosts (browserpass, tridactyl, etc.) should now work."

    deploy_user_js
}

deploy_user_js() {
    local user_js="$BASEDIR/browsing/user.js"
    if [[ ! -f "$user_js" ]]; then
        log_warn "firefox-deb" "browsing/user.js not found, skipping deployment."
        return
    fi

    # Find the Firefox profile directory
    local firefox_dir
    for candidate in "$HOME/.config/mozilla/firefox" "$HOME/.mozilla/firefox"; do
        if [[ -f "$candidate/profiles.ini" ]]; then
            firefox_dir="$candidate"
            break
        fi
    done

    if [[ -z "$firefox_dir" ]]; then
        log_warn "firefox-deb" "No Firefox profile found. Launch Firefox once, then re-run this script."
        return
    fi

    # Parse the active profile path from the [Install*] section
    local profile_path
    profile_path=$(awk -F= '/^\[Install/{found=1} found && /^Default=/{print $2; exit}' "$firefox_dir/profiles.ini")

    if [[ -z "$profile_path" ]]; then
        log_warn "firefox-deb" "Could not determine default profile from profiles.ini."
        return
    fi

    local profile_dir="$firefox_dir/$profile_path"
    if [[ ! -d "$profile_dir" ]]; then
        log_warn "firefox-deb" "Profile directory $profile_dir does not exist."
        return
    fi

    log_step "firefox-deb" "Deploying user.js to $profile_dir..."
    ln -sf "$user_js" "$profile_dir/user.js"
    log_step "firefox-deb" "user.js deployed. Restart Firefox for changes to take effect."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    run
fi
