# telegram-desktop's firejail profile, built around disable-all.inc

include globals.local

include no-private-lib.inc
include allow-usr-share.inc
include allow-networking.inc
include allow-multimedia.inc
include allow-fontconfig.inc

join-or-start telegram-desktop

ignore no3d
ignore machine-id
ignore memory-deny-write-execute

ignore private

mkdir ${HOME}/.local/share/TelegramDesktop
whitelist ${HOME}/.local/share/TelegramDesktop
noblacklist ${HOME}/.local/share/TelegramDesktop

whitelist ${HOME}/.config/qt6ct
read-only ${HOME}/.config/qt6ct

mkdir ${DOWNLOADS}
whitelist ${DOWNLOADS}

dbus-user filter
ignore dbus-user none
dbus-user.own org.telegram.desktop.*
dbus-user.talk org.freedesktop.Notifications
dbus-user.talk org.freedesktop.ScreenSaver

include disable-all.inc

private-bin telegram-desktop,sh
private-etc alternatives,ca-certificates,crypto-policies,fonts,group,ld.so.cache,ld.so.preload,localtime,machine-id,os-release,passwd,pki,pulse

# vim:ft=firejail