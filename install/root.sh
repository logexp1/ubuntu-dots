#!/bin/bash
set -e
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/common.sh"

SYSTEM_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")/system"

run() {
    log_step "root" "Installing system root files..."

    while IFS= read -r -d '' src; do
        local rel="${src#$SYSTEM_DIR/}"
        local dest="/$rel"
        local dest_dir
        dest_dir="$(dirname "$dest")"

        sudo mkdir -p "$dest_dir"
        sudo cp "$src" "$dest"
        sudo chown root:root "$dest"
        sudo chmod 755 "$dest"

        log_step "root" "Installed $dest"
    done < <(find "$SYSTEM_DIR" -type f -print0)

    log_step "root" "Done."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    run
fi
