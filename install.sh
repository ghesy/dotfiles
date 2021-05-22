#!/bin/sh
# this script installs the dotfiles.

# check if gnu stow is installed
which stow >/dev/null || exit 1 # check if gnu stow is installed

# make directories that shouldn't be symlinks. if these dirs don't
# exist, stow will create them as a symlink and anything put in them
# is going to go to go amongst the dotfiles.
mkdir -p ~/.config ~/.local/bin ~/.local/share/applications \
    ~/.local/share/wall ~/.local/sv/run
( cd ~/.config;  mkdir -p qalculate tremc kicad pulse transmission-daemon \
    safeeyes gtk-2.0 gtk-3.0 )

# install all the dotfile packages one by one.
# if we try to install them all at once (by running stow */),
# stow will abort the whole thing upon having a problem and that's annoying.
for pkg in */; do
    stow -v "$pkg"
done
