#!/bin/sh
# this script enables dns caching using unbound.

# install packages
pkg() { pacman -Q "$@" >/dev/null 2>&1 || pacman -S --needed "$@" || exit 1 ;}
pkg openresolv unbound unbound-runit

install -DCvm644 dns.conf /etc/NetworkManager/conf.d/dns.conf
install -DCvm644 unbound.conf /etc/unbound/unbound.conf
install -DCvm644 resolvconf.conf /etc/resolvconf.conf
install -DCvm755 update-resolv.sh /etc/windscribe/update-resolv.sh

# enable unbound's service
ln -vs /etc/runit/sv/unbound /run/runit/service/ 2>/dev/null
