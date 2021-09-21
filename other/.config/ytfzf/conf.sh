thumb_disp_method=custom
handle_display_img() {
    PID=$(pgrep -xns0 ytfzf)
    sxipc "$PID"
    sxip "$5" "$1" "$2" "$3" "$4" "$PID" "$PID"
}
