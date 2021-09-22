#!/bin/sh
# this script configures makepkg to use aria2 for downloading files.
command -v aria2c >/dev/null || pacman -S --needed aria2 || exit 1
install -DCvm644 makepkg.extra.conf /etc/makepkg.extra.conf
f=/etc/makepkg.conf
[ -e $f ] && ! fgrep -q '. /etc/makepkg.extra.conf' $f &&
    printf '\n%s\n%s\n' '# include custom configs' '. /etc/makepkg.extra.conf' >> $f &&
    echo Updated $f.
