#!/bin/sh
# This script downloads the currently playing video using yt-dlp.

[ -f "${1:?}" ] && exit 1
cd /media/downloads || cd ~/Downloads || cd ~ || exit 1

quality=$(printf '480p\n720p\n1080p\n360p\n' | dmenu -p Choose\ Quality ${WINDOWID:+-w $WINDOWID}) || exit 1
quality=${quality%p}
quality="bestvideo[height=${quality:?}]+bestaudio/best[height=$quality]/bestvideo[height<=$((quality*2))]+bestaudio/best[height<=$((quality*2))]/bestvideo+bestaudio/best"

yt-dlp -f "$quality" -N 8 --add-metadata --sub-lang=en \
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
