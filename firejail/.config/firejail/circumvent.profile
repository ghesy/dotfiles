include globals.local

include disable-common.inc
include disable-devel.inc
include disable-interpreters.inc

machine-id
netfilter
no3d
nodvd
nogroups
noinput
nonewprivs
nosound
notv
nou2f
novideo
protocol unix,inet,inet6
seccomp
shell none
x11 none

disable-mnt
private-tmp
private-dev

mkdir ${HOME}/.local/share/circumvent
whitelist ${HOME}/.local/share/circumvent
