#!/bin/sh
conf=/etc/makepkg.conf
[ ! -e $conf ] && exit 1
grep -q '\. /etc/makepkg-extra.conf' $conf && exit
printf '\n%s\n%s\n' '# include custom configs' '. /etc/makepkg-extra.conf' >> $conf
echo Updated $conf.
