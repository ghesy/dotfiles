#!/bin/bash
# /etc/windscribe/update-resolv.sh
split_into_parts() { part1="$1"; part2="$2"; part3="$3" ;}
case "$script_type" in
    up)
        for optionvarname in ${!foreign_option_*} ; do
            option="${!optionvarname}"; echo "$option"
            split_into_parts $option
            [ "$part1" = "dhcp-option" ] && [ "$part2" = "DNS" ] &&
                echo "nameserver $part3" | resolvconf -x -a windscribe
        done
    ;;
    down) resolvconf -d windscribe; resolvconf -u; resolvconf -r unbound ;;
esac
