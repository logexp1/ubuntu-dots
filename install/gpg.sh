#!/bin/bash
set -e
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/common.sh"

KEY_ID="360913AC5912FEB8"
PRIVKEY_PATH="$HOME/OneDrive/privkey.asc"
PASS_REPO="https://github.com/logexp1/password-store.git"
PASS_DIR="$HOME/.password-store"

# Returns true only if real secret key material is present (not a stub)
has_real_secret_key() {
    gpg --list-secret-keys --with-colons "$KEY_ID" 2>/dev/null | grep -q '^sec:'
}


run() {
    if [[ $EUID -eq 0 ]]; then
        log_error "gpg" "Do not run as root — this corrupts GPG keyring ownership."
        return 1
    fi

    log_step "gpg" "Setting up GnuPG and password store..."
    require_cmd pass

    # Fix ownership/permissions if a previous root run corrupted the keyring
    if [[ -d "$HOME/.gnupg" ]]; then
        sudo chown -R "$USER:$USER" "$HOME/.gnupg"
        find "$HOME/.gnupg" -type d -exec chmod 700 {} \;
        find "$HOME/.gnupg" -type f -exec chmod 600 {} \;
    fi

    # Ensure OneDrive is synced so privkey.asc is available
    if [[ ! -f "$PRIVKEY_PATH" ]]; then
        require_cmd onedrive
        if [[ ! -f "$HOME/.config/onedrive/refresh_token" ]]; then
            log_step "gpg" "OneDrive not authenticated. Starting interactive authentication..."
            onedrive
        fi
        log_step "gpg" "Syncing OneDrive in background..."
        onedrive --sync &
        local onedrive_pid=$!

        local timeout=1800
        local elapsed=0
        log_step "gpg" "Waiting for $PRIVKEY_PATH..."
        while [[ ! -f "$PRIVKEY_PATH" ]]; do
            if [[ $elapsed -ge $timeout ]]; then
                kill "$onedrive_pid" 2>/dev/null || true
                log_error "gpg" "Timed out waiting for privkey.asc after ${timeout}s."
                log_error "gpg" "Run 'onedrive --sync' manually, wait for it to finish, then re-run this script."
                return 1
            fi
            if ! kill -0 "$onedrive_pid" 2>/dev/null; then
                log_error "gpg" "onedrive exited before privkey.asc was found."
                return 1
            fi
            sleep 2
            elapsed=$((elapsed + 2))
        done
        log_step "gpg" "Found privkey.asc after ${elapsed}s."
    fi

    # Remove use-keyboxd if present — restart agents so they pick up the change
    if grep -q 'use-keyboxd' "$HOME/.gnupg/common.conf" 2>/dev/null; then
        sed -i '/use-keyboxd/d' "$HOME/.gnupg/common.conf"
        [[ ! -s "$HOME/.gnupg/common.conf" ]] && rm -f "$HOME/.gnupg/common.conf"
        gpgconf --kill keyboxd 2>/dev/null || true
        gpgconf --kill gpg-agent 2>/dev/null || true
    fi

    # Ensure gpg-agent is running before any key operations
    gpgconf --launch gpg-agent

    # Import private key if real secret material is not yet present
    if has_real_secret_key; then
        log_step "gpg" "Secret key already in keyring, skipping import."
    else
        if [[ ! -f "$PRIVKEY_PATH" ]]; then
            log_error "gpg" "Private key not found at $PRIVKEY_PATH"
            return 1
        fi
        log_step "gpg" "Importing private key from $PRIVKEY_PATH..."
        gpg --import "$PRIVKEY_PATH"
        if ! has_real_secret_key; then
            log_error "gpg" "Import succeeded but secret key material is missing."
            log_error "gpg" "$PRIVKEY_PATH may not contain the real private key."
            return 1
        fi
    fi

    # Resolve full fingerprint
    local fingerprint
    fingerprint="$(gpg --list-keys --with-colons "$KEY_ID" | awk -F: '/^fpr:/ { print $10; exit }')"

    # Set trust to ultimate (idempotent)
    log_step "gpg" "Setting key trust to ultimate..."
    echo "${fingerprint}:5:" | gpg --import-ownertrust
    gpg --check-trustdb

    # Remove expiration on primary key and all subkeys (idempotent)
    log_step "gpg" "Removing key expiration..."
    gpg --quick-set-expire "$fingerprint" 0 '*'

    # Clone password store and initialise (only on first setup)
    if [[ -d "$PASS_DIR" ]]; then
        log_step "gpg" "Password store already exists at $PASS_DIR, skipping."
    else
        log_step "gpg" "Cloning password store..."
        git clone "$PASS_REPO" "$PASS_DIR"
        log_step "gpg" "Initializing password store with key $KEY_ID..."
        pass init "$KEY_ID"
    fi

    log_step "gpg" "Done."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    run
fi
