#!/bin/sh
f=/etc/nsswitch.conf
[ ! -w $f ] && exit 1
grep -q mdns4 $f && exit 0
sed 's/files resolve/files mdns4_minimal [NOTFOUND=return] resolve/' $f
