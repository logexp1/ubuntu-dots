#!/bin/bash
set -e
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/common.sh"

run() {
    log_step "git" "Configuring global git settings..."
    require_cmd git
    require_cmd pass

    git config --global user.email "jisoo.h.lee@gmail.com"
    git config --global user.name "Jisoo Lee"
    git config --global credential.helper '!pass-git-helper $@'

    log_step "git" "Initializing password store..."
    pass git init
    pass git remote add origin "https://github.com/mlmaniac/password-store.git"
    pass git pull origin master --allow-unrelated-histories --rebase

    log_step "git" "Done."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    run
fi
