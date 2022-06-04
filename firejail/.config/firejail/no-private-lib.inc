# don't privatize /usr/lib, but disable as much of it as possible

ignore private-lib
include disable-common.inc
include disable-devel.inc
include disable-interpreters.inc

# vim:ft=firejail
