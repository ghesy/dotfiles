shortcuts=alt-l,alt-t,alt-o,alt-v,ctrl-alt-d,alt-m,alt-s,alt-enter,alt-d
enable_fzf_default_opts=1
thumb_disp_method=custom

handle_display_img() {
    PID=$(pgrep -xns0 ytfzf)
    sxipc "$PID"
    sxip "$5" "$1" "$2" "$3" "$4" "$PID" "$PID"
}

handle_custom_shortcuts() {
    case $selected_key in alt-d)
        setsid -f $TERMINAL -e ytdl $selected_urls >/dev/null 2>&1
        return 2
    ;; esac
}
