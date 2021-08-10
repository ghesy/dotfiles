#!/bin/sh

# check if gnu stow is installed
! command -v stow >/dev/null && echo Please install stow. && exit 1

# make these directories so that stow can't create them as symlinks
l=~/.local; s=$l/share c=~/.config
mkdir -p $l/bin $l/sv/run $s/applications $s/gnupg $c/tremc $c/kicad \
    $c/safeeyes $c/pulse $c/gtk-2.0 $c/gtk-3.0 $c/transmission-daemon

# install the dotfiles
stow -v */
