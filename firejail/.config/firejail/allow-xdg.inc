# include this in case any program needs xdg support

include allow-usr-share.inc

whitelist ${HOME}/.local/share/mime
read-only ${HOME}/.local/share/mime

whitelist ${HOME}/.local/share/icons
read-only ${HOME}/.local/share/mime

whitelist ${HOME}/.local/share/applications
read-only ${HOME}/.local/share/applications

whitelist ${HOME}/.config/mimeapps.list
read-only ${HOME}/.config/mimeapps.list

noblacklist ${RUNUSER}
whitelist ${RUNUSER}/firexdg
blacklist ${RUNUSER}/firexdg-notsandboxed

private-bin xdg-open

# vim:filetype=firejail
