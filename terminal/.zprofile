#!/bin/sh

# XDG settings
# source /etc/profile.d/flatpak.sh

pathdirs="
/usr/local/cuda/bin
$HOME/.config/emacs/bin
$HOME/.local/bin
$HOME/.cargo/bin
"

while read -r dir; do
	if [[ -n $dir ]] && [[ ! ${dir:0:1} == '#' ]]; then
		PATH="$PATH":"$dir"
	fi
done <<< "$pathdirs"

export PATH

WIRELESS_INTERFACE=$(ip link \
	| awk -F ":" '/^[0-9]: wl/ {sub(" ",""); print $2}')
ETHERNET_INTERFACE=$(ip link \
	| awk -F ":" '/^[0-9]: en/ {sub(" ",""); print $2}')

export WIRELESS_INTERFACE ETHERNET_INTERFACE
