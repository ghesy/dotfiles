#!/bin/sh
# install a script for cleaning up pacman's cache.
install -DCvm644 pkgcache.hook -t /usr/share/libalpm/hooks/
install -DCvm755 pkgcache -t /usr/bin/
