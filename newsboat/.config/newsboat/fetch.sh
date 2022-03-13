#!/bin/sh
# this is an "execurl" script for newsboat.
# look up newsboat's man page for more info.
$(getproxy "${1:?}") curl -fsL --connect-timeout 30 -- "${1:?}"
