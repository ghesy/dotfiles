# this firejail profile disables as much stuff as possible.

include globals.local

# the /proc and /run dirs cannot be successfully blacklisted;
# but these two incs disable as much of them as possible
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

# make required directories private
private
private-bin true
private-etc resolv.conf,nsswitch.conf,hosts,host.conf,
private-lib
private-tmp

# blacklist everything else
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

# disable as much of /dev as possible
private-dev
no3d
nodvd
nosound
notv
nou2f
novideo
noprinters

# vim:ft=firejail
