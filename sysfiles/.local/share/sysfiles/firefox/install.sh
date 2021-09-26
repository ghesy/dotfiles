#!/bin/sh
# install firefox, pywalfox and a privacy-oriented user.js.

# install packages
pkg() { pacman -Q "$@" >/dev/null 2>&1 || paru -S --needed "$@" || exit 1 ;}
pkg firefox python-pywalfox

# get user's home directory
HOME=$(getent passwd ${SUDO_USER:?} | cut -d: -f6)

# install the user.js file
printf '%s\n' $HOME/.mozilla/firefox/*.*/ |
    xargs -d'\n' -L1 install -DCvm644 -o $SUDO_USER -g $SUDO_USER user.js -t

# install pywalfox
[ ! -e ${HOME:?}/.mozilla/native-messaging-hosts/pywalfox.json ] &&
    chmod -v 755 $(runuser -u $SUDO_USER -g $SUDO_USER pywalfox install | grep -Eom1 '\S+main.sh')
