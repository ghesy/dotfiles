#!/bin/sh
# install firejail and add firejail symlinks for some programs in /usr/local/bin.

# install firejail
pacman -Q firejail >/dev/null || pacman -S --needed firejail || exit 1

# add symlinks
for n in discord teamspeak3 anydesk everdo; do
    ln -fs /usr/bin/firejail /usr/local/bin/$n
done

# remind the user to install hardened_malloc
pacman -Q hardened_malloc >/dev/null 2>&1 ||
    echo Please install hardened_malloc from the AUR.
