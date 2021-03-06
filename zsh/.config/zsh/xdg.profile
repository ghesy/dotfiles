# vim:filetype=zsh

export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$HOME"/.config/java
export ANSIBLE_CONFIG=~/.config/ansible/ansible.cfg
export NPM_CONFIG_USERCONFIG=~/.config/npm/config
export GTK2_RC_FILES=~/.config/gtk-2.0/gtkrc-2.0
export NOTMUCH_CONFIG=~/.config/notmuch-config
export GTK_RC_FILES=~/.config/gtk-1.0/gtkrc
export ANDROID_SDK_HOME=~/.config/android
export XINITRC=~/.config/X11/xinitrc
export WGETRC=~/.config/wget/wgetrc
export INPUTRC=~/.config/inputrc
export GRIPHOME=~/.config/grip
export ZDOTDIR=~/.config/zsh

export PASSWORD_STORE_DIR=~/.local/share/password-store
export TS3_CONFIG_DIR=~/.local/share/ts3client
export RUSTUP_HOME=~/.local/share/rustup
export PYLINTHOME=~/.local/share/pylint
export CARGO_HOME=~/.local/share/cargo
export GNUPGHOME=~/.local/share/gnupg
export KODI_DATA=~/.local/share/kodi
export UNISON=~/.local/share/unison
export GEM_HOME=~/.local/share/gem
export NVM_DIR=~/.local/share/nvm
export GOPATH=~/.local/share/go
export GOBIN="$GOPATH/bin"

export PARALLEL_HOME=~/.cache/parallel && mkdir -p "$PARALLEL_HOME"
export NUGET_PACKAGES=~/.cache/NuGetPackages
export GEM_SPEC_CACHE=~/.cache/gem

export PIPX_BIN_DIR=~/.local/bin/pipx
export ABDUCO_SOCKET_DIR=$XDG_RUNTIME_DIR
