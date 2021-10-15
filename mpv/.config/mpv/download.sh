#!/bin/sh
# This script downloads the currently playing video using yt-dlp.

[ -f "${1:?}" ] && exit 1
cd /media/downloads || cd ~/Downloads || cd ~ || exit 1
res=$(printf '480\n720\n1080\n360\n' | dmenu -p Resolution: ${WINDOWID:+-w $WINDOWID}) || exit 1

yt-dlp -S "res:$res,abr~$((res/5))" -N 8 --add-metadata --sub-lang=en \
    --write-sub --write-auto-sub --embed-subs \
    --compat-options no-keep-subs -- "${1#ytdl://*}"

case $? in
    0) echo Download finished.
        read x
        exec $SHELL ;;
    *) echo Download failed.
        read x
        exit ;;
esac
