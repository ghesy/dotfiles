#!/bin/bash
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
line='sv check elogind >/dev/null && sleep 1 || exit 1'
sed -i "s@^sv check elogind .*@${line//&/\\&}@" ${sv:?}/run
grep -q '^sv check elogind' ${sv:?}/run || sed -i "2i $line" ${sv:?}/run
