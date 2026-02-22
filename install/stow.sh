#!/bin/bash
set -e
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/common.sh"

PACKAGES=(emacs terminal wm remap common)
TARGET="$HOME"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"

backup_conflicts() {
    for pkg in "${PACKAGES[@]}"; do
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
    log_step "stow" "Stowing dotfiles..."
    require_cmd stow

    backup_conflicts
    stow -Rvt "$TARGET" -d "$BASEDIR" "${PACKAGES[@]}"
    log_step "stow" "Done."
}

unstow() {
    log_step "stow" "Unstowing dotfiles..."
    require_cmd stow

    stow -Dvt "$TARGET" -d "$BASEDIR" "${PACKAGES[@]}"
    log_step "stow" "Done."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    case "${1:-}" in
        --unstow|-D) unstow ;;
        *)           run ;;
    esac
fi
