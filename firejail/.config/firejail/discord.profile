# discord's firejail profile, built around disable-all.inc
name discord
join-or-start discord

include globals.local

include no-private-lib.inc
include no-hardened-malloc.inc
include allow-networking.inc
include allow-multimedia.inc
include allow-fontconfig.inc
include allow-dragon-drop.inc
include allow-xdg-open.inc

ignore private

mkdir ${HOME}/.config/discord
whitelist ${HOME}/.config/discord

# don't allow discord to overwrite settings.json
read-only ${HOME}/.config/discord/settings.json

mkdir ${DOWNLOADS}
whitelist ${DOWNLOADS}

noblacklist /opt
whitelist /opt/discord

x11 xephyr
ignore apparmor
ignore noexec ${HOME}
ignore memory-deny-write-execute

dbus-user filter
ignore dbus-user none
dbus-user.talk org.freedesktop.Notifications # enable native notifications

include disable-all.inc

seccomp !chroot
private-bin discord

# vim:filetype=firejail
