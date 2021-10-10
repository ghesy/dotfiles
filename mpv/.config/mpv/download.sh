#!/bin/sh
# This script downloads the currently playing video.
# requires aria2 and youtube-dl.

# config
aria2_args='-c -k1M -x16 -s16 --async-dns=false'

# if the given argument is a file (therefore not a link), exit
[ -f "${1:?}" ] && exit 1

# go to download destination
cd /media/downloads || cd ~/Downloads || cd ~ || exit 1

# ask the desired quality via dmenu
quality=$(printf '480p\n720p\n1080p\n360p\n' | dmenu -p Choose\ Quality ${WINDOWID:+-w $WINDOWID}) || exit 1
quality=${quality%p}
quality="bestvideo[height=${quality:?}]+bestaudio/best[height=$quality]/bestvideo[height<=$((quality*2))]+bestaudio/best[height<=$((quality*2))]/bestvideo+bestaudio/best"

ytdl() {
    ytdlp_args='-N 8 --compat-options no-keep-subs'
    ytdl=youtube-dl
    if command -v yt-dlp >/dev/null; then
        ytdl=yt-dlp
    elif [ ! -L $(command -v youtube-dl) ]; then
        ytdlp_args=''
    fi
    $ytdl -f "$quality" --sub-lang=en --write-sub --write-auto-sub \
        --embed-subs --external-downloader aria2c \
        --external-downloader-args "$aria2_args" $ytdlp_args -- "$@"
}

echo Downloading to "$PWD"...
url=${1#ytdl://*}
ytdl "$url" || aria2c $aria2_args -- "$url" &&
    echo Download Finished. ||
    echo Download Failed.
echo Press Enter.
read x
exec $SHELL
