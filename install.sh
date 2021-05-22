#!/bin/sh
# this script installs the dotfiles.

# check if gnu stow is installed
! which stow >/dev/null && echo install stow && exit 1

# make directories that shouldn't be folded. if we don't create
# them now, stow will create them as symlinks and any other file
# that goes in there, will end up amongst our dotfiles, which is not ok.
# read more on folding in stow's manpage.
mkdir -p ~/.local/bin ~/.local/share/applications ~/.local/share/wall \
    ~/.local/sv/run ~/.config/tremc ~/.config/kicad ~/.config/safeeyes \
    ~/.config/pulse ~/.config/gtk-2.0 ~/.config/gtk-3.0 \
    ~/.config/transmission-daemon

# install all the dotfile packages one by one.
# if we try to install them all at once (by running 'stow */'),
# stow will abort the whole thing on any error, and that's annoying.
for pkg in */; do
    stow -v "$pkg"
done
