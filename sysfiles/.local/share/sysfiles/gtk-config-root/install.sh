#!/bin/sh
# this script copies user's gtk configuration to the root user's home,
# to have the same theme for gtk applications running as root.
root=/root/.config
gtk2=gtk-2.0/gtkrc-2.0
gtk3=gtk-3.0/settings.ini
[ ! -e $root/$gtk2 -o ! -e $root/$gtk3 ] &&
    mkdir -p ${root:?}/gtk-2.0 ${root:?}/gtk-3.0 &&
    cp /home/*/.config/$gtk2 $root/$gtk2 &&
    cp /home/*/.config/$gtk3 $root/$gtk3 &&
    echo Installed root\'s gtk configs.
