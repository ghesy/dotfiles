# allow x11 and sound

ignore x11 none
ignore nosound

noblacklist ${RUNUSER}
whitelist ${RUNUSER}/pulse/native
whitelist ${RUNUSER}/pipewire-?

private-etc pulse,X11

# vim:ft=firejail
