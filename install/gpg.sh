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

# Returns true if a valid (non-expired) encryption subkey exists
has_valid_encrypt_subkey() {
    gpg --list-keys --with-colons "$KEY_ID" 2>/dev/null | awk -F: '
        $1 == "sub" && $12 ~ /e/ {
            expiry = $7; now = systime()
            if (expiry == "" || expiry == "0" || expiry+0 > now) found=1
        }
        END { exit !found }
    '
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
        log_step "gpg" "Syncing OneDrive..."
        onedrive --synchronize
        if [[ ! -f "$PRIVKEY_PATH" ]]; then
            log_error "gpg" "privkey.asc still not found at $PRIVKEY_PATH after sync."
            return 1
        fi
    fi

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
    echo "${fingerprint}:6:" | gpg --import-ownertrust
    gpg --check-trustdb

    # Remove expiration on primary key and all subkeys (idempotent)
    log_step "gpg" "Removing key expiration..."
    gpg --quick-set-expire "$fingerprint" 0 '*'

    # Ensure a valid (non-expired) encryption subkey exists
    if ! has_valid_encrypt_subkey; then
        log_step "gpg" "No valid encryption subkey found, adding one..."
        gpg --quick-add-key "$fingerprint" rsa4096 encr 0
        log_warn "gpg" "New subkey added. Update your backup:"
        log_warn "gpg" "  gpg --export-secret-keys --armor $KEY_ID > $PRIVKEY_PATH"
    else
        log_step "gpg" "Encryption subkey valid, skipping."
    fi

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
