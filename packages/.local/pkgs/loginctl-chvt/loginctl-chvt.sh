#!/bin/sh
# a wrapper for loginctl that switches to tty6 before suspend.
# an elogind hook will then switch back to the previous tty
# after waking up from suspend.

# config
sparetty=6
origtty=/run/origtty

set -e

[ $# -eq 0 ] && exec /usr/bin/loginctl

# the --chvt option is for internal use
if [ "$1" = --chvt ]; then
    shift
    /usr/bin/loginctl lock-sessions
    sleep 0.5
    fgconsole > "$origtty"
    chvt "${sparetty:?}"
    exec /usr/bin/loginctl "$@"
fi

for arg; do
    case $arg in
        -*) continue ;;
        suspend|hibernate|hybrid-sleep|suspend-then-hibernate)
            exec sudo -- "$0" --chvt "$@"
        ;;
        *) break ;;
    esac
done

exec /usr/bin/loginctl "$@"
