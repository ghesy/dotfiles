# firefox's firejail profile, built around disable-all.inc
name firefox

include globals.local

include no-private-lib.inc
include no-hardened-malloc.inc
include allow-multimedia.inc
include allow-usr-share.inc
include allow-networking.inc
include allow-fontconfig.inc
include allow-gtk-configs.inc
include allow-dragon-drop.inc
include allow-xdg-open.inc

ignore private

mkdir ${HOME}/.mozilla
whitelist ${HOME}/.mozilla
noblacklist ${HOME}/.mozilla

mkdir ${HOME}/.cache/mozilla/firefox
whitelist ${HOME}/.cache/mozilla/firefox
noblacklist ${HOME}/.cache/mozilla/firefox

mkdir ${HOME}/.pki
whitelist ${HOME}/.pki
noblacklist ${HOME}/.pki

mkdir ${HOME}/.local/share/pki
whitelist ${HOME}/.local/share/pki
noblacklist ${HOME}/.local/share/pki

mkdir ${DOWNLOADS}
whitelist ${DOWNLOADS}

ignore no3d
ignore novideo
ignore ipc-namespace
ignore memory-deny-write-execute
noblacklist /sys

dbus-user filter
ignore dbus-user none
dbus-user.own org.mozilla.Firefox.*
dbus-user.own org.mozilla.firefox.*
dbus-user.own org.mpris.MediaPlayer2.firefox.* # enable mpris support
dbus-user.talk org.freedesktop.Notifications # enable native notifications
dbus-user.talk org.freedesktop.ScreenSaver # allow inhibiting screensavers

include disable-all.inc

seccomp !chroot
private-bin firefox,sh,bash,env,which,dbus-launch,dbus-send
private-etc machine-id,pki,pango,passwd,group,mime.types,mailcap

# vim:filetype=firejail
