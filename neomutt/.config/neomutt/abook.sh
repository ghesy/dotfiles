#!/bin/sh
# run abook with changed config and addressbook paths

# show everything in the alternate buffer
printf '\033[?1049h\033[H'

# run abook
abook --config ~/.config/neomutt/abook.conf \
    --datafile ~/.local/share/neomutt/mailbook/addressbook "$@"
