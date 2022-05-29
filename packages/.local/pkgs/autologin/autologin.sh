#!/bin/sh
# /usr/share/libalpm/scripts/autologin
sed -i 's|--noclear|--noclear --autologin koonix|' /run/runit/service/agetty-tty1/conf
sed -i 's|^Exec=.*|Exec=/bin/false|' /usr/share/dbus-1/system-services/org.freedesktop.login1.service
