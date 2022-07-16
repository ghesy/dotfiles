# drawio's firejail profile, built around disable-all.inc
name drawio

include globals.local

include no-private-lib.inc
include allow-usr-share.inc
include allow-multimedia.inc
include allow-fontconfig.inc
include allow-gtk-configs.inc
include allow-gpu.inc

ignore private

mkdir ${HOME}/.config/draw.io
whitelist ${HOME}/.config/draw.io

mkdir ${DOWNLOADS}
whitelist ${DOWNLOADS}

noblacklist /opt
whitelist /opt/drawio

ignore memory-deny-write-execute

include disable-all.inc

seccomp !chroot
private-bin drawio

# vim:filetype=firejail
