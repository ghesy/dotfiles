#!/bin/sh
# this script installs an rc.local file to do some stuff on startup.
command -v ntpd >/dev/null || pacman -S --needed ntp || exit 1
install -DCvm755 rc.local /etc/rc.local
