#!/bin/bash
set -e
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/common.sh"

run() {
    log_step "git" "Configuring global git settings..."
    require_cmd git

    git config --global user.email "jisoo.h.lee@gmail.com"
    git config --global user.name "Jisoo Lee"
    git config --global credential.helper '!pass-git-helper $@'
    git config --global credential.https://oss.navercorp.com.username jisoo.h.lee

    log_step "git" "Done."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    run
fi
