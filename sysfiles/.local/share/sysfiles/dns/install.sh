#!/bin/sh
# this script enables dns-over-https and dns caching.

# install packages
pkg() { pacman -Q "$@" >/dev/null 2>&1 || pacman -S --needed "$@" || exit 1 ;}
pkg unbound unbound-runit dns-over-https dns-over-https-runit

install -DCvm644 resolv.conf /etc/resolv.conf
install -DCvm644 dns.conf /etc/NetworkManager/conf.d/dns.conf
install -DCvm644 unbound.conf /etc/unbound/unbound.conf
install -DCvm644 doh-client.conf /etc/dns-over-https/doh-client.conf

# enable services of unbound and dns-over-https
ln -vs /etc/runit/sv/unbound    /run/runit/service/ 2>/dev/null
ln -vs /etc/runit/sv/doh-client /run/runit/service/ 2>/dev/null
