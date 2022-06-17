# teamspeak3's firejail profile, built around disable-all.inc
name teamspeak3

include globals.local

include no-private-lib.inc
include no-hardened-malloc.inc
include allow-usr-share.inc
include allow-networking.inc
include allow-multimedia.inc
include allow-fontconfig.inc
include allow-dragon-drop.inc
include allow-xdg.inc

ignore memory-deny-write-execute

noblacklist /opt
whitelist /opt/teamspeak3

ignore private

mkdir ${HOME}/.local/share/ts3client
whitelist ${HOME}/.local/share/ts3client

mkdir ${DOWNLOADS}
whitelist ${DOWNLOADS}

include disable-all.inc

seccomp !chroot
private-bin teamspeak3,bash

# vim:ft=firejail
