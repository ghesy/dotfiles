# allow x11 and sound

ignore x11 none
ignore nosound
ignore machine-id

noblacklist ${RUNUSER}
whitelist ${RUNUSER}/pulse/native
whitelist ${RUNUSER}/pipewire-?

private-etc pulse,X11

# vim:ft=firejail
