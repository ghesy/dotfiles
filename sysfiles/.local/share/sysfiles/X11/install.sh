#!/bin/sh
# this script installs X11 configs for touchpads and disabling blanking.
install -DCvm644 *.conf -t /etc/X11/xorg.conf.d
