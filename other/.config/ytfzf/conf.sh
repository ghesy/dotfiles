is_loop=1
enable_hist=1
show_thumbnails=1

thumbnail_quality=high
thumbnail_viewer=img_display_function
img_display_function() {
    [ "$1" != view ] && return 0
    sxipc "$YTFZF_PID"
    sxip "$2" "$5" "$6" "$3" "$4" "$YTFZF_PID" "$YTFZF_PID"
}

download_shortcut=ctrl-alt-d
custom_shortcut_binds=alt-d
handle_custom_keypresses() {
    case $1 in
        alt-d)
            setsid -f ${TERMINAL:?} -e ytdl $(cat "$ytfzf_selected_urls") >/dev/null 2>&1
            return 0 ;;
    esac
}

thumbnail_video_info_text () {
    [ -n "$title" ] && printf "\n ${c_cyan}%s" "$title"
    [ -n "$channel" ] && printf "\n ${c_blue}Channel  ${c_green}%s" "$channel"
    [ -n "$duration" ] && printf "\n ${c_blue}Duration ${c_yellow}%s" "$duration"
    [ -n "$views" ] && printf "\n ${c_blue}Views    ${c_magenta}%s" "$views"
    [ -n "$date" ] && printf "\n ${c_blue}Date     ${c_cyan}%s" "$date"
    [ -n "$url" ] && urlhost=${url#https://} && printf "\n ${c_blue}Source   ${c_reset}%s" "${urlhost%%/*}"
    [ -n "$description" ] && printf "\n ${c_blue}Description${c_reset}: %s" "$(printf "%s" "$description" | sed 's/\\n/\n/g')"
}
