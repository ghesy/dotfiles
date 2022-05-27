# this firejail profile disables as much stuff as possible.

include globals.local
include disable-proc.inc
include whitelist-run-common.inc
include enable-hardened-malloc.inc

# basic stuff
caps.drop all
seccomp
seccomp.block-secondary
nonewprivs
net none
x11 none
netfilter
protocol unix
dbus-system none
dbus-user none
ipc-namespace
shell none

# make stuff private
private
private-bin true
private-etc resolv.conf,nsswitch.conf,hosts,host.conf,
private-lib
private-tmp

# blacklist unneeded stuff
disable-mnt
blacklist /opt
blacklist /srv
blacklist /sys
blacklist /usr/etc
blacklist /usr/include
blacklist /usr/local
blacklist /usr/share
blacklist /usr/src
blacklist /var
blacklist /.Trash
blacklist ${RUNUSER}

# disable stuff in /dev
private-dev
no3d
nodvd
nosound
notv
nou2f
novideo
noprinters
