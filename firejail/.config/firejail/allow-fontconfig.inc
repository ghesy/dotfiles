# whitelist and enable fontconfig configs, libraries and binaries

whitelist ${HOME}/.config/fontconfig
read-only ${HOME}/.config/fontconfig
whitelist ${HOME}/.dots/fontconfig
read-only ${HOME}/.dots/fontconfig
whitelist ${HOME}/.cache/fontconfig
read-only ${HOME}/.cache/fontconfig

private-etc fonts
private-bin fc-match,fc-list
private-lib libfontconfig.so,libexpat.so,libfreetype.so,libfribidi.so

# vim:filetype=firejail
