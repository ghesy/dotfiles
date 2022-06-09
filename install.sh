#!/bin/sh

# cd to the script's directory
cd "$(dirname "$(readlink -f "${0:?}")")" || exit 1

# check if gnu stow is installed
! command -v stow >/dev/null && echo Please install stow. && exit 1

# make these directories so that stow can't create them as symlinks
l=~/.local s=$l/share c=~/.config
mkdir -p $l/bin $l/sv/run $s/applications $s/gnupg $c/kicad \
    $c/pulse $c/gtk-2.0 $c/gtk-3.0 $c/transmission-daemon \
    $s/local/profile.d $s/local/xinitrc.d $s/local/gimme/aliases.d

# install the dotfiles
stow -v */ || exit 1

# copy default configs to their destination
(cd ~/.config/tuir && cp -vLn tuir.def.cfg tuir.cfg)
(cd ~/.config/transmission-daemon && cp -vLn settings.def.json settings.json)
