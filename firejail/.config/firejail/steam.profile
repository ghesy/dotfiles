# steam's firejail profile

include globals.local

mkdir ${HOME}/.local/share/SteamHome
private ${HOME}/.local/share/SteamHome

noblacklist ${HOME}/.local/share/Steam

noblacklist ${HOME}/.config/Epic
noblacklist ${HOME}/.config/Loop_Hero
noblacklist ${HOME}/.config/MangoHud
noblacklist ${HOME}/.config/ModTheSpire
noblacklist ${HOME}/.config/RogueLegacy
noblacklist ${HOME}/.config/RogueLegacyStorageContainer
noblacklist ${HOME}/.killingfloor
noblacklist ${HOME}/.klei
noblacklist ${HOME}/.local/share/3909/PapersPlease
noblacklist ${HOME}/.local/share/aspyr-media
noblacklist ${HOME}/.local/share/bohemiainteractive
noblacklist ${HOME}/.local/share/cdprojektred
noblacklist ${HOME}/.local/share/Dredmor
noblacklist ${HOME}/.local/share/FasterThanLight
noblacklist ${HOME}/.local/share/feral-interactive
noblacklist ${HOME}/.local/share/HotlineMiami
noblacklist ${HOME}/.local/share/IntoTheBreach
noblacklist ${HOME}/.local/share/Paradox Interactive
noblacklist ${HOME}/.local/share/PillarsOfEternity
noblacklist ${HOME}/.local/share/RogueLegacy
noblacklist ${HOME}/.local/share/RogueLegacyStorageContainer
noblacklist ${HOME}/.local/share/Steam
noblacklist ${HOME}/.local/share/SteamWorldDig
noblacklist ${HOME}/.local/share/SteamWorld Dig 2
noblacklist ${HOME}/.local/share/SuperHexagon
noblacklist ${HOME}/.local/share/Terraria
noblacklist ${HOME}/.local/share/vpltd
noblacklist ${HOME}/.local/share/vulkan
noblacklist ${HOME}/.mbwarband
noblacklist ${HOME}/.paradoxinteractive
noblacklist ${HOME}/.prey
noblacklist ${HOME}/.steam
noblacklist ${HOME}/.steampath
noblacklist ${HOME}/.steampid

noblacklist /sbin
noblacklist /usr/sbin

include allow-java.inc
include allow-python2.inc
include allow-python3.inc
include disable-common.inc
include disable-devel.inc
include disable-interpreters.inc
include disable-programs.inc
include disable-xdg.inc
include whitelist-var-common.inc

disable-mnt
private-dev
private-tmp
private-etc alsa,alternatives,asound.conf,bumblebee,ca-certificates,crypto-policies,dbus-1,drirc,fonts,group,gtk-2.0,gtk-3.0,host.conf,hostname,hosts,ld.so.cache,ld.so.conf,ld.so.conf.d,ld.so.preload,localtime,lsb-release,machine-id,mime.types,nvidia,os-release,passwd,pki,pulse,resolv.conf,services,ssl,vulkan

nonewprivs
caps.drop all
seccomp !chroot,!mount,!name_to_handle_at,!pivot_root,!ptrace,!umount2
protocol unix,inet,inet6,netlink
netfilter
shell none
noroot
nogroups
novideo
nodvd
notv
nou2f

# vim:filetype=firejail
