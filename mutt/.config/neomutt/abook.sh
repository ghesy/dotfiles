#!/bin/sh
# run abook with changed config and addressbook paths

# show everything in the alternate buffer
trap exit INT TERM HUP
trap "printf '\e[?1049l'" EXIT
printf '\e[?1049h'
printf '\e[H'

# run abook
abook \
    --config ~/.config/neomutt/abook.conf \
    --datafile ~/.local/share/neomutt/mailbook/addressbook "$@" ||
    case "$1" in
        *query*) notify-send NeoMutt 'Failed fetching emails from the addressbook' ;;
        *add*) notify-send NeoMutt 'Failed adding the email to the addressbook' ;;
    esac

# send a key to exit out of neomutt's prompt
xdotool key period
