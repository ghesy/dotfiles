#!/bin/sh
# This script shows the description and comments of an internet video.
# requires jq, youtube-dl, pipe-viewer.
set -- "${1#ytdl://*}"
{
if [ -f "${1:?}" ]; then
    echo Description:
    mediainfo --Output=JSON "${1:?}" | jq -r '.media.track[0].Description' | sed 's/ \/ /\n/g' | fold -sw70
    set -- "$(mediainfo --Output=JSON "${1:?}" | jq -r '.media.track[0].extra.PURL')"
else
    echo Description:
    p=$(getproxy "$1")
    $p youtube-dl -jq "${1:?}" 2>/dev/null | jq -r .description
fi
printf '\nComments:\n'
$p pipe-viewer --no-interactive --no-use-colors --comments="${1:?}"
} 2>/dev/null | nvim -c 'setlocal nomodified nomodifiable'
