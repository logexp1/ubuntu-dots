#!/bin/bash
set -e
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/common.sh"

KEY_ID="360913AC5912FEB8"
KEYSERVER="hkps://keyserver.ubuntu.com"
PRIVKEY_PATH="$HOME/OneDrive/privkey.asc"

run() {
    log_step "gpg" "Setting up GnuPG and password store..."
    require_cmd gpg
    require_cmd pass

    # Import public key from keyserver
    log_step "gpg" "Importing public key $KEY_ID from $KEYSERVER..."
    gpg --keyserver "$KEYSERVER" --recv-keys "$KEY_ID"

    # Import private key
    if [[ -f "$PRIVKEY_PATH" ]]; then
        log_step "gpg" "Importing private key from $PRIVKEY_PATH..."
        gpg --import "$PRIVKEY_PATH"
    else
        log_error "gpg" "Private key not found at $PRIVKEY_PATH"
        log_error "gpg" "Please sync OneDrive first, then re-run this module."
        return 1
    fi

    # Set trust to ultimate
    log_step "gpg" "Setting key trust to ultimate..."
    echo "${KEY_ID}:6:" | gpg --import-ownertrust

    # Remove expiration
    log_step "gpg" "Removing key expiration..."
    gpg --quick-set-expire "$KEY_ID" 0

    # Initialize pass with this key
    log_step "gpg" "Initializing password store..."
    pass init "$KEY_ID"

    log_step "gpg" "Cloning password store repo..."
    pass git init
    pass git remote add origin "https://github.com/logexp1/password-store.git"
    pass git pull origin master --allow-unrelated-histories --rebase

    log_step "gpg" "Done."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    run
fi
