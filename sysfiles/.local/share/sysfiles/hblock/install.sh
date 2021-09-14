#!/bin/sh
# this script installs hblock-related scripts, files and cron jobs.
command -v hblock >/dev/null || paru -S --needed hblock || exit 1
install -DCvm755 hblock-aria2 /usr/local/bin/hblock-aria2
install -DCvm755 hblock.cron  /etc/cron.daily/hblock
install -DCvm644 sources.list header -t /etc/hblock
