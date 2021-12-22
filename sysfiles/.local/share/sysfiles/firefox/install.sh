#!/bin/sh
# install firefox, pywalfox and a privacy-oriented user.js.

# install firefox
command -v firefox >/dev/null || pacman -S --needed firefox || exit 1

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
pacman -Q python-pywalfox >/dev/null 2>&1 || {
    echo Please install python-pywalfox form the AUR and run this again to install it\'s config files.
    exit 1
}
grep -q lib/"$(basename "$(readlink -f /bin/python)")" "${HOME:?}"/.mozilla/native-messaging-hosts/pywalfox.json ||
    runuser -u "$SUDO_USER" -g "${group:-nobody}" pywalfox install | grep -v permi
chmod -c 755 $(pacman -Qql python-pywalfox | grep main.sh)
