#!/bin/bash
set -e
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/common.sh"

PACKAGES_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")/packages"

default_pm() {
    case "$OS" in
        linux-debian) echo "apt" ;;
        linux-arch)   echo "pacman" ;;
        linux-fedora) echo "dnf" ;;
        macos)        echo "brew" ;;
        *)
            log_error "packages" "Cannot determine default package manager for OS: $OS"
            return 1
            ;;
    esac
}

install_with() {
    local pm="$1"
    local pkg="$2"

    case "$pm" in
        apt)
            sudo apt install -y "$pkg"
            ;;
        pacman)
            sudo pacman -S --noconfirm "$pkg"
            ;;
        dnf)
            sudo dnf install -y "$pkg"
            ;;
        brew)
            brew install "$pkg"
            ;;
        yay)
            yay -S --noconfirm "$pkg"
            ;;
        npm)
            npm install -g "$pkg"
            ;;
        pip)
            pip install --user "$pkg"
            ;;
        cargo)
            cargo install "$pkg"
            ;;
        *)
            log_error "packages" "Unknown package manager: $pm"
            return 1
            ;;
    esac
}

run() {
    log_step "packages" "Installing packages for $OS..."

    local pkg_file="$PACKAGES_DIR/$OS"
    if [[ ! -f "$pkg_file" ]]; then
        log_error "packages" "No package list found at $pkg_file"
        return 1
    fi

    local default
    default="$(default_pm)"

    while IFS= read -r line || [[ -n "$line" ]]; do
        # skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

        local pkg pm
        pkg="$(echo "$line" | awk '{print $1}')"
        pm="$(echo "$line" | awk '{print $2}')"
        pm="${pm:-$default}"

        log_step "packages" "Installing $pkg with $pm..."
        install_with "$pm" "$pkg"
    done < "$pkg_file"

    log_step "packages" "Done."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    run
fi
