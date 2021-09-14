#!/bin/sh
# this script configures makepkg to use aria2 for downloading files.
install -DCvm644 makepkg.extra.conf /etc/makepkg.extra.conf
f=/etc/makepkg.conf
[ -e $f ] && ! fgrep -q '. /etc/makepkg.extra.conf' $f &&
    printf '\n%s\n%s\n' '# include custom configs' '. /etc/makepkg.extra.conf' >> $f &&
    echo Updated $f.
