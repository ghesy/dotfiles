#!/bin/sh
root=/root/.config
gtk2=gtk-2.0/gtkrc-2.0
gtk3=gtk-3.0/settings.ini

[ -e $root/$gtk2 ] && [ -e $root/$gtk3 ] && exit 0

mkdir -p $root/gtk-2.0 $root/gtk-3.0
cp -n /home/*/.config/$gtk2 $root/$gtk2
cp -n /home/*/.config/$gtk3 $root/$gtk3

echo Installed gtk configs for the root user.
