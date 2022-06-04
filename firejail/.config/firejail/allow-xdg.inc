# include this in case any program needs xdg support

whitelist ${HOME}/.local/share/mime
whitelist ${HOME}/.local/share/icons

whitelist ${HOME}/.local/share/applications
read-only ${HOME}/.local/share/applications

whitelist ${HOME}/.config/mimeapps.list
read-only ${HOME}/.config/mimeapps.list

# vim:ft=firejail
