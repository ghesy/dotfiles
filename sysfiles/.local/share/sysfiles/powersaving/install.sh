#!/bin/sh
# only install these files if the machine is a laptop
case $(cat /sys/class/dmi/id/chassis_type) in
    9|10|11|14) ;;
    *) exit ;;
esac

# install the required packages
pkg() { pacman -Q "$@" >/dev/null 2>&1 || pacman -S --needed "$@" || exit 1 ;}
pkg hdparm light

install -DCvm644 udev/* -t /etc/udev/rules.d
install -DCvm644 sysctl.d/* -t /etc/sysctl.d
install -DCvm644 modprobe.d/* -t /etc/modprobe.d
install -DCvm755 elogind/* -t /etc/elogind/system-sleep
install -DCvm755 pwr /usr/local/bin/pwr
