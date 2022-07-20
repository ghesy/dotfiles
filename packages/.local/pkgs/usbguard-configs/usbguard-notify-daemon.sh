#!/bin/sh
#
# a companion for usbguard.
#
# this script runs as a daemon and does two things:
#
#   1. notify when devices are blocked by usbguard; the notification will have
#        actions for allowing the blocked device temporarily or permamently
#
#   2. notify when a keyboard is plugged in that is not in the list of
#        trusted keyboards; the notifications will have actions for adding
#        the keyboard to the list of allowed keyboards.
#
# requires libnotify.

# config
trusted_keyboards_list=~/.local/share/usbguard/trusted-keyboards.list

main()
{
    # kill any leftover child processes on termination
    trap 'pkill -P$$' HUP INT TERM

    # parse options
    unset verbose
    case $1 in
        -v|--verbose) verbose=true ;;
        -h|--help) print_help; return ;;
    esac

    # make the required files and directories
    init_files

    # verify the connected keyboards on startup
    verify_keyboards

    usbguard watch | while IFS= read -r line; do
        case $line in
            *'[device] '*)
                unset event target name hash
                id=${line##*=}
                case $line in
                    *PresenceChanged*) mode=presence ;;
                    *) mode=policy ;;
                esac
        esac
        case $line in
            ' event='*)
                event=${line#*=} ;;
            ' target='*|' target_new='*)
                target=${line#*=}; target=${target%% *} ;;
            ' device_rule='*)
                name=${line#*\" name \"}; name=${name%%\"*}
                hash=${line#*\" hash \"}; hash=${hash%%\"*} ;;
        esac
        case $mode/$line in
            presence/' device_rule='*|policy/' rule_id='*)
                case $event/$target in
                    Remove/*)
                        vmsg "Removed: $name" ;;
                    */allow)
                        vmsg "Allowed: $name"
                        verify_keyboards ;;
                    Insert/*)
                        vmsg "Inserted: $name" ;;
                    */reject)
                        vmsg "Rejected: $name"
                        notif "Rejected: $name"
                    ;;
                    */block)
                        vmsg "Blocked: $name"
                        notify_blocked_device & ;;
                esac
        esac
    done &

    wait
}

notify_blocked_device() {
    case $(notif "Blocked: $name" -A 'Allow Permanently' -A 'Allow') in
        0)
            usbguard allow-device "$id" &&
                usbguard append-rule "allow name \"$name\" hash \"$hash\"" &&
                notif "Permanently Allowed: $name" ;;
        1)
            usbguard allow-device "$id" &&
                notif "Allowed: $name" ;;
    esac
}

verify_keyboards()
{
    for kbhash in $(list_active_keyboards); do
        is_keyboard_trusted "$kbhash" && continue
        kbname=$(get_keyboard_name "$kbhash")
        notify_untrusted_keyboard &
    done
}

notify_untrusted_keyboard()
{
    shorthash=$(printf '%s\n' "$kbhash" | cut -c1-7)
    notifmsg="Untrusted Keyboard: $kbname ($shorthash)"
    if [ "$(notif -u critical "$notifmsg" -A Trust)" = 0 ]
    then
        init_files &&
            printf '%s\n' "$kbhash" >> "$trusted_keyboards_list" &&
            notif "Trusted: $kbname"
    fi
}

list_active_keyboards()
{
    usbguard list-devices | grep -E ': allow .*03:0[01]:01' |
        grep -v '03:0[01]:02' | grep -Po ' hash "\K[^"]+'
}

get_keyboard_name()
{
    usbguard list-devices | grep -F "$1" | grep -Po ' name "\K[^"]+'
}

is_keyboard_trusted()
{
    [ -f "$trusted_keyboards_list" ] &&
        grep -Fxq "$1" "$trusted_keyboards_list"
}

notif()
{
    notify-send 'USBGuard' "$@"
}

vmsg()
{
    [ "$verbose" = true ] && printf '%s\n' "$*"
}

init_files()
{
    set -eu
    mkdir -p "${trusted_keyboards_list%/*}"
    touch "$trusted_keyboards_list"
    chmod 600 "$trusted_keyboards_list"
    set +eu
}

print_help()
{
cat << EOF
usage:
  ${0##*/} [-v|--verbose]

a companion for usbguard.

this script runs as a daemon and does two things:

  1. notify when devices are blocked by usbguard; the notification will have
       actions for allowing the blocked device temporarily or permamently

  2. notify when a keyboard is plugged in that is not in the list of
       trusted keyboards; the notifications will have actions for adding
       the keyboard to the list of allowed keyboards.

EOF
}

main "$@"
