# this firejail profile disables as much stuff as possible.
# other profiles can include this and then only allow the stuff that's needed.

# the /proc and /run dirs cannot be successfully blacklisted;
# but these two incs disable as much of them as possible
include disable-proc.inc
include whitelist-run-common.inc

# noexec some important dirs
include disable-exec.inc

# basic stuff
noroot
nogroups
apparmor
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
machine-id
memory-deny-write-execute

# make required directories private
private
private-bin true
private-etc resolv.conf,nsswitch.conf,hosts,host.conf,crypto-policies,ld.so.cache,ld.so.conf,ld.so.conf.d,ld.so.preload
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
noinput
nosound
notv
nou2f
novideo
noprinters

# in dynamically-allocated programs, load and use hardened_malloc:
# https://wiki.archlinux.org/title/Firejail#Use_with_hardened_malloc
# https://github.com/GrapheneOS/hardened_malloc
env LD_PRELOAD=/usr/lib/libhardened_malloc.so
private-lib libhardened_malloc.so

# vim:ft=firejail
