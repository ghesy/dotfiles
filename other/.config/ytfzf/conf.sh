is_loop=1
enable_hist=1
show_thumbnails=1
pages_to_scrape=2

video_player() {
    sxipc "$YTFZF_PID"
    pipeurl "$@"
}

audio_player() {
    sxipc "$YTFZF_PID"
    pipeurl --audio "$@"
}

downloader() {
    setsid -f ${TERMINAL:?} -e ytdl "$@" >/dev/null 2>&1
}

thumbnail_quality=high
thumbnail_viewer=previewfn
previewfn() {
    [ "$1" != view ] && return 0
    sxipc "$YTFZF_PID"
    sxip "$2" "$5" "$6" "$3" "$(($4+3))" "$YTFZF_PID" "$YTFZF_PID"
}

numshorten() {
    if [ "$1" -ge 1000000000 ]; then
        awk -v i="$1" 'BEGIN{printf("%.1fB\n", i/10^9)}'
    elif [ "$1" -ge 1000000 ]; then
        awk -v i="$1" 'BEGIN{printf("%.1fM\n", i/10^6)}'
    elif [ "$1" -ge 1000 ]; then
        awk -v i="$1" 'BEGIN{printf("%.1fK\n", i/10^3)}'
    else
        echo "$1"
    fi
}

thumbnail_video_info_text () {
    [ -n "$title" ] && printf "${c_cyan}%s\n" "$title" | fold -sw "$FZF_PREVIEW_COLUMNS"
    [ -n "$channel" ] && printf "${c_blue}Channel  ${c_green}%s\n" "$channel"
    [ -n "$duration" ] && printf "${c_blue}Duration ${c_yellow}%s\n" "$duration"
    [ -n "$views" ] && printf "${c_blue}Views    ${c_magenta}%s\n" "$(numshorten "$views")"
    [ -n "$date" ] && printf "${c_blue}Date     ${c_cyan}%s\n" "$date"
    [ -n "$url" ] && urlhost=${url#https://} && printf "${c_blue}Source   ${c_reset}%s\n" "${urlhost%%/*}"
    [ -n "$description" ] && printf "${c_blue}Description${c_reset}: %s\n" "$(printf "%s" "$description" | sed 's/\\n/\n/g')"
}

video_pref='bestvideo[height>=360]+bestaudio/bestvideo+bestaudio/best[height>=360]/best'
