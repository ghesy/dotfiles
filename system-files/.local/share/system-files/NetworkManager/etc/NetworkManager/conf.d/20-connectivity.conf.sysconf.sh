#!/bin/sh
dir=/etc/NetworkManager/conf.d
grep -q 'uri=' $dir/* 2>/dev/null && exit 1
file="$(grep -l connectivity /usr/lib/NetworkManager/conf.d/*)" || exit 1
file="$(echo "$file" | head -n1)"
grep -q 'uri=' "$file" || exit 1
awk '/uri=/ { print; print "interval=30"; next } 1' "$file" \
    > $dir/"$(basename "$file")" || exit 1
echo "Decreased NetworkManager's connectivity check interval."
