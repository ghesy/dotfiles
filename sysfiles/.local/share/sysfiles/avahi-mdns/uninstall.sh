#!/bin/sh
pacman -Rns nss-mdns avahi-runit || exit 1
sudo rm /run/runit/service/avahi-daemon
sudo rm -rf /etc/runit/sv/avahi-daemon/supervise
sudo rmdir  /etc/runit/sv/avahi-daemon
grep -q 'hosts:.*mdns4' $f &&
    sed -i '/hosts:/ s/mdns4_minimal [NOTFOUND=return]//' $f &&
    echo Updated $f.
