#!/bin/sh
file="$(grep -l connectivity /usr/lib/NetworkManager/conf.d/*)" || exit 1
file="$(echo "$file" | head -n1)"
grep -q 'uri=' "$file" || exit 1
awk '/uri=/ { print; print "interval=30"; next } 1' "$file" \
    > /etc/NetworkManager/conf.d/"$(basename "$file")" || exit 1
