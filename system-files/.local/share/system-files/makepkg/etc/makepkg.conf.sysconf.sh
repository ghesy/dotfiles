#!/bin/sh

conf=/etc/makepkg.conf

main() {
    grep -q aria2c $conf || dlagents
    grep -q nproc $conf || makeflags
    grep -q 'ZST.*0' $conf || zstdflags
}

dlagents() {
cat << 'eof' >> $conf
DLAGENTS=('file::/usr/bin/aria2c --no-conf --min-split-size=1M --summary-interval=0 --max-connection-per-server=2 -o %o %u'
          'ftp::/usr/bin/aria2c --ftp-pasv --no-conf --min-split-size=1M --summary-interval=0 --max-connection-per-server=2 -o %o %u'
          'http::/usr/bin/aria2c --no-conf --min-split-size=1M --summary-interval=0 --max-connection-per-server=2 -o %o %u'
          'https::/usr/bin/aria2c --no-conf --min-split-size=1M --summary-interval=0 --max-connection-per-server=2 -o %o %u'
          'rsync::/usr/bin/rsync --no-motd -z %u %o'
          'scp::/usr/bin/scp -C %u %o')
eof
}

makeflags() {
cat << 'eof' >> $conf
MAKEFLAGS=-j$(nproc)
eof
}

zstdflags() {
cat << 'eof' >> $conf
COMPRESSZST=(zstd -c -z -q -T0 -)
eof
}

main "$@"
