#!/bin/sh
# /usr/share/libalpm/scripts/autologin

# config
user=koonix
tty=1

# disable elogind being started through dbus
sed -i 's|^Exec=.*|Exec=/bin/false|' /usr/share/dbus-1/system-services/org.freedesktop.login1.service

# service directory
sv=/run/runit/service/agetty-tty${tty:?}

# configure agetty to autologin
sed -Ei 's|(\S*GETTY_ARGS=).*|\1"--noclear --autologin '"${user:?}"'"|' ${sv:?}/conf

# make agetty's service wait for elogind
grep -q 'sv check elogind' ${sv:?}/run ||
    sed -i '2i sv check elogind >/dev/null || exit 1' ${sv:?}/run
