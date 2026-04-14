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
    local extra="${3:-}"

    case "$pm" in
        apt)
            sudo apt install -y "$pkg"
            if [[ "$pkg" == "npm" ]]; then
                log_step "packages" "Configuring npm prefix to ~/.local..."
                npm config set prefix "$HOME/.local"
            fi
            if [[ "$pkg" == "rustup" ]]; then
                log_step "packages" "Initializing rustup with stable toolchain..."
                rustup default stable
                source "$HOME/.cargo/env"
            fi
            ;;
        pacman)
            sudo pacman -S --noconfirm "$pkg"
            ;;
        dnf)
            sudo dnf install -y "$pkg"
            ;;
        dnf-repo)
            local repo_id
            repo_id=$(basename "$extra" .repo)
            if ! sudo dnf repolist --enabled | grep -q "^$repo_id"; then
                sudo dnf config-manager addrepo --from-repofile="$extra"
            fi
            sudo dnf install -y --repo "$repo_id" "$pkg"
            ;;
        brew)
            brew install "$pkg"
            ;;
        yay)
            yay -S --noconfirm "$pkg"
            ;;
        npm)
            if ! npm config get prefix 2>/dev/null | grep -q "$HOME"; then
                npm config set prefix "$HOME/.local"
            fi
            npm install -g "$pkg"
            ;;
        pip)
            pip install --user "$pkg"
            ;;
		pipx)
			if ! command -v pipx &>/dev/null; then
				log_step "packages" "pipx not found, installing..."
				case "$OS" in
					linux-fedora) sudo dnf install -y pipx ;;
					linux-debian) sudo apt install -y pipx ;;
					linux-arch)   sudo pacman -S --noconfirm python-pipx ;;
				esac
			fi
			pipx install "$pkg" || pipx upgrade "$pkg"
			;;
		cargo)
			if ! command -v cargo &>/dev/null; then
				log_step "packages" "cargo not found, installing rustup..."
				case "$OS" in
					linux-fedora) sudo dnf install -y rustup && rustup-init -y ;;
					linux-debian) sudo apt install -y rustup && rustup default stable ;;
					linux-arch)   sudo pacman -S --noconfirm rust ;;
				esac
				source "$HOME/.cargo/env"
			fi
			if [[ "$pkg" == git+* ]]; then
				local git_url="${pkg#git+}"
				local git_bin=""
				if [[ "$git_url" == *#* ]]; then
					git_bin="${git_url#*#}"
					git_url="${git_url%#*}"
				fi
				cargo install --git "$git_url" ${git_bin:+"$git_bin"}
			else
				cargo install "$pkg" --locked
			fi
            ;;
        *)
            log_error "packages" "Unknown package manager: $pm"
            return 1
            ;;
    esac
}

run() {
    log_step "packages" "Installing packages for $OS..."

    if [[ "$OS" == "linux-debian" ]]; then
        log_step "packages" "Updating apt package index..."
        sudo apt update -qq
    fi


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

        local pkg pm extra
        pkg="$(echo "$line" | awk '{print $1}')"
        pm="$(echo "$line" | awk '{print $2}')"
        pm="${pm:-$default}"
        extra="$(echo "$line" | awk '{print $3}')"

        log_step "packages" "Installing $pkg with $pm..."
        install_with "$pm" "$pkg" "$extra"
    done < "$pkg_file"

    log_step "packages" "Done."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    run
fi
