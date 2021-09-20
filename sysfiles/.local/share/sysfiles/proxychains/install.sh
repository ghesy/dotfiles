#!/bin/sh
# this script installs proxychains and configures it.
command -v proxychains >/dev/null || pacman -S --needed proxychains || exit 1
install -DCvm644 proxychains.conf /etc/proxychains.conf
