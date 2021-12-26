#!/bin/sh
# this script installs sblock's lists.

install -DCvm644 *.list -t /etc/sblock

# generate and install the /etc/sblock/header file
f=/etc/sblock/header
sum1=$(sha256sum <$f)

echo "127.0.0.1 localhost
127.0.1.1 $(uname -n).localdomain $(uname -n)
::1 localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
" > $f

cat safesearch >> $f
sum2=$(sha256sum <$f)
[ "$sum1" != "$sum2" ] && echo Updated $f.
