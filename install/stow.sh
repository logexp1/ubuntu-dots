#!/bin/bash
set -e
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/common.sh"

EXCLUDE=(install)
TARGET="$HOME"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"

discover_packages() {
    local packages=()
    for dir in "$BASEDIR"/*/; do
        [[ ! -d "$dir" ]] && continue
        local name
        name="$(basename "$dir")"
        local excluded=false
        for ex in "${EXCLUDE[@]}"; do
            [[ "$name" == "$ex" ]] && excluded=true && break
        done
        $excluded || packages+=("$name")
    done
    echo "${packages[@]}"
}

backup_conflicts() {
    local packages=("$@")
    for pkg in "${packages[@]}"; do
        local pkg_dir="$BASEDIR/$pkg"
        [[ -d "$pkg_dir" ]] || continue

        find "$pkg_dir" -mindepth 1 -maxdepth 1 -name '.*' -type d | while read -r dotdir; do
            local dotname
            dotname="$(basename "$dotdir")"

            if [[ "$dotname" == ".config" ]]; then
                find "$dotdir" -mindepth 1 -maxdepth 1 -type d | while read -r subdir; do
                    local subname target_path backup
                    subname="$(basename "$subdir")"
                    target_path="$TARGET/.config/$subname"
                    if [[ -d "$target_path" && ! -L "$target_path" ]]; then
                        backup="$target_path.backup.$TIMESTAMP"
                        log_step "stow" "Backing up $target_path -> $backup"
                        mv "$target_path" "$backup"
                    fi
                done
            else
                local target_path backup
                target_path="$TARGET/$dotname"
                if [[ -d "$target_path" && ! -L "$target_path" ]]; then
                    backup="$target_path.backup.$TIMESTAMP"
                    log_step "stow" "Backing up $target_path -> $backup"
                    mv "$target_path" "$backup"
                fi
            fi
        done
    done
}

run() {
    log_step "stow" "Discovering stow packages..."
    require_cmd stow

    local packages
    read -ra packages <<< "$(discover_packages)"

    if [[ ${#packages[@]} -eq 0 ]]; then
        log_warn "stow" "No stow packages found."
        return 0
    fi

    log_step "stow" "Packages: ${packages[*]}"

    backup_conflicts "${packages[@]}"
    stow -Rvt "$TARGET" -d "$BASEDIR" "${packages[@]}"
    log_step "stow" "Done."
}

unstow() {
    log_step "stow" "Discovering stow packages..."
    require_cmd stow

    local packages
    read -ra packages <<< "$(discover_packages)"

    if [[ ${#packages[@]} -eq 0 ]]; then
        log_warn "stow" "No stow packages found."
        return 0
    fi

    log_step "stow" "Packages: ${packages[*]}"

    stow -Dvt "$TARGET" -d "$BASEDIR" "${packages[@]}"
    log_step "stow" "Done."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    case "${1:-}" in
        --unstow|-D) unstow ;;
        *)           run ;;
    esac
fi
