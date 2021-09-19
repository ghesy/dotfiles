#!/bin/sh
# this script installs hblock-related scripts, files and cron jobs.
command -v hblock >/dev/null || paru -S --needed hblock || exit 1
install -DCvm755 hblock-aria2 /usr/local/bin/hblock-aria2
install -DCvm755 hblock.cron  /etc/cron.daily/hblock
install -DCvm644 sources.list /etc/hblock/sources.list

# generate and install the /etc/hblock/header file
f=/etc/hblock/header
sum1=$(sha256sum <$f)
hostname=$(uname -n)
printf "::1 localhost\n127.0.0.1 localhost\n127.0.1.1 %s.localdomain %s\n\n" "$hostname" "$hostname" > $f
cat google-safesearch >> $f
sum2=$(sha256sum <$f)
[ "$sum1" != "$sum2" ] && echo Updated $f.
