#!/bin/sh
# this script enables local hostname resolution:
# https://wiki.archlinux.org/title/avahi#Hostname_resolution

# install nss-mdns
pkg() { pacman -Q "$@" >/dev/null 2>&1 || pacman -S --needed "$@" || exit 1 ;}
pkg nss-mdns avahi-runit

# enable avahi's service
ln -vs /etc/runit/sv/avahi-daemon /run/runit/service 2>/dev/null

# add mdns4_minimal to /etc/nsswitch.conf
f=/etc/nsswitch.conf
grep -q 'hosts:.*mdns4' $f && exit
sed -i '/hosts:/ s/resolve/mdns4_minimal [NOTFOUND=return] resolve/' $f &&
    echo Updated $f.
