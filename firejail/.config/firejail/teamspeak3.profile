# teamspeak3's firejail profile, built around disable-all.inc

noblacklist /opt
whitelist /opt/teamspeak3

noblacklist ${RUNUSER}
whitelist ${RUNUSER}/pulse/native
whitelist ${RUNUSER}/pipewire-?

noblacklist /usr/share
include whitelist-usr-share-common.inc

ignore private
ignore private-lib
ignore net none
ignore x11 none
ignore nosound
ignore include enable-hardened-malloc.inc

include disable-all.inc
include enable-fontconfig.inc

seccomp !chroot
protocol unix,inet,inet6,netlink
private-bin teamspeak3,sh,dash,bash
private-etc ca-certificates,ssl

mkdir ${HOME}/.local/share/ts3client
whitelist ${HOME}/.local/share/ts3client
