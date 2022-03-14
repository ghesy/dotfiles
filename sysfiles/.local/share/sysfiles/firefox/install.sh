#!/bin/sh
# install firefox and a privacy-oriented user.js.

# install firefox
command -v firefox >/dev/null || pacman -S --needed firefox || exit 1

# get user's home directory and group
HOME=$(getent passwd "${SUDO_USER:?}" | cut -d: -f6)
group=$(id -gn "$SUDO_USER")

# install the user.js file
printf '%s\n' "$HOME"/.mozilla/firefox/*.*/ |
    xargs -d'\n' -L1 install -DCvm644 -o "$SUDO_USER" -g "${group:-nobody}" user.js -t
