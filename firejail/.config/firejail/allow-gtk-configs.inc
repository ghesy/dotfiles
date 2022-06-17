# whitelist and enable gtk configs

whitelist ${HOME}/.config/gtk-3.0
whitelist ${HOME}/.config/gtk-2.0

read-only ${HOME}/.config/gtk-3.0/settings.ini
read-only ${HOME}/.config/gtk-2.0/gtkrc-2.0

whitelist ${HOME}/.dots/gtk
read-only ${HOME}/.dots/gtk

private-etc gtk-3.0,gtk-2.0

# vim:ft=firejail
