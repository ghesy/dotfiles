#!/bin/sh
root=/root/.config
mkdir -p $root/gtk-2.0 $root/gtk-3.0
cp -n /home/*/.config/gtk-2.0/gtkrc-2.0 $root/gtk-2.0/
cp -n /home/*/.config/gtk-3.0/settings.ini $root/gtk-3.0/
echo Installed gtk configs for the root user.
