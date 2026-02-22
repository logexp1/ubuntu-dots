#!/bin/bash
set -e
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/common.sh"

KEY_ID="360913AC5912FEB8"
KEYSERVER="hkps://keyserver.ubuntu.com"
PRIVKEY_PATH="$HOME/OneDrive/privkey.asc"
PASS_REPO="https://github.com/logexp1/password-store.git"
PASS_DIR="$HOME/.password-store"

run() {
    log_step "gpg" "Setting up GnuPG and password store..."
    require_cmd pass

    # Import public key from keyserver
    if gpg --list-keys "$KEY_ID" &>/dev/null; then
        log_step "gpg" "Public key $KEY_ID already in keyring, skipping import."
    else
        log_step "gpg" "Importing public key $KEY_ID from $KEYSERVER..."
        gpg --keyserver "$KEYSERVER" --recv-keys "$KEY_ID"
    fi

    # Import private key
    if gpg --list-secret-keys "$KEY_ID" &>/dev/null; then
        log_step "gpg" "Private key $KEY_ID already in keyring, skipping import."
    else
        if [[ -f "$PRIVKEY_PATH" ]]; then
            log_step "gpg" "Importing private key from $PRIVKEY_PATH..."
            gpg --import "$PRIVKEY_PATH"
        else
            log_error "gpg" "Private key not found at $PRIVKEY_PATH"
            log_error "gpg" "Please sync OneDrive first, then re-run this module."
            return 1
        fi
    fi

    # Resolve full fingerprint
    local fingerprint
    fingerprint="$(gpg --list-keys --with-colons "$KEY_ID" | awk -F: '/^fpr:/ { print $10; exit }')"

    # Set trust to ultimate (idempotent)
    log_step "gpg" "Setting key trust to ultimate..."
    echo "${fingerprint}:6:" | gpg --import-ownertrust

    # Remove expiration (idempotent)
    log_step "gpg" "Removing key expiration..."
    gpg --quick-set-expire "$fingerprint" 0

    # Clone password store repo, then init with key
    if [[ -d "$PASS_DIR" ]]; then
        log_step "gpg" "Password store already exists at $PASS_DIR, skipping clone."
    else
        log_step "gpg" "Cloning password store..."
        git clone "$PASS_REPO" "$PASS_DIR"
    fi

    log_step "gpg" "Initializing password store with key $KEY_ID..."
    pass init "$KEY_ID"

    log_step "gpg" "Done."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    run
fi
