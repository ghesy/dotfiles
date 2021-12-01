#!/bin/sh

# check if gnu stow is installed
! command -v stow >/dev/null && echo Please install stow. && exit 1

# make these directories so that stow can't create them as symlinks
l=~/.local; s=$l/share c=~/.config
mkdir -p $l/bin $l/sv/run $s/applications $s/gnupg $c/kicad \
    $c/pulse $c/gtk-2.0 $c/gtk-3.0 $c/transmission-daemon $c/tv \
    $s/local/profile.d $s/local/xinitrc.d $s/local/gimme/aliases.d

# install the dotfiles
stow -v */ || exit 1

# install system configurations
printf 'Install sysfiles? [y/N] '
read ans
case "$ans" in y|Y) ;; *) exit ;; esac
for d in ~/.local/share/sysfiles/*/; do
    cd "$d" && sudo ./install.sh
done
