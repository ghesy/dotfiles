#!/bin/sh
# install firefox, pywalfox and a privacy-oriented user.js.

# install packages
pkg() { pacman -Q "$@" >/dev/null 2>&1 || paru -S --needed "$@" || exit 1 ;}
pkg firefox python-pywalfox

# get user's home directory and group
HOME=$(getent passwd "${SUDO_USER:?}" | cut -d: -f6)
group=$(id -gn "$SUDO_USER")

# install the user.js file
printf '%s\n' "$HOME"/.mozilla/firefox/*.*/ |
    xargs -d'\n' -L1 install -DCvm644 -o "$SUDO_USER" -g "${group:-nobody}" user.js -t

# install HideContainersIcon.css
printf '%schrome\n' "$HOME"/.mozilla/firefox/*.*/ |
    xargs -d'\n' -L1 install -DCvm644 -o "$SUDO_USER" -g "${group:-nobody}" HideContainersIcon.css -Dt

# install pywalfox
[ ! -e "${HOME:?}"/.mozilla/native-messaging-hosts/pywalfox.json ] &&
    chmod -v 755 $(runuser -u "$SUDO_USER" -g "${group:-nobody}" pywalfox install | grep -Eom1 '\S+main.sh')
