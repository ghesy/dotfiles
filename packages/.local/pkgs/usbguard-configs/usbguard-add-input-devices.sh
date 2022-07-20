#!/bin/bash
# add rules to usbguard to to allow the currently connected mice and keyboards.

# config path
conf=/etc/usbguard/rules.conf

IFS=$'\n'
for device in $(usbguard list-devices | grep -E '03:0[01]:0[12]');
do
    name=${device#*\" name \"}; name=${name%%\"*}
    hash=${device#*\" hash \"}; hash=${hash%%\"*}
    rule="allow name \"$name\" hash \"$hash\""
    shorthash=${hash:0:7}

    if sudo grep -Fxq "$rule" "$conf"; then
        echo "already added: $name ($shorthash)"
    else
        printf '%s' "add \"$name\" ($shorthash) ? [y/N] "
        read -r ans
        if [ "$ans" = y ] || [ "$ans" = Y ]; then
            printf '%s\n' "$rule" | sudo tee --append "$conf" >/dev/null &&
                echo "added \"$name\" ($shorthash)."
        fi
    fi
done
