# zsh aliases, functions and bindings.
# it's sourced in .zshrc.

# with this, you can fzf zsh's history with ctrl-r,
# and add files as args with ctrl-t.
source /usr/share/fzf/key-bindings.zsh

lsd() { /usr/bin/ls --color=always --classify --group-directories-first "$@" }

ls() {
    maxwidth=80
    width=$(tput cols)
    [ $width -gt $maxwidth ] && width=$maxwidth
    lsd -Aw$width "$@"
}

alias l=' ls'
alias l1=' lsd -A1'
alias ll=' lsd -hal'

lf() {
    lfrun "$@"
    cd "$(lflast "$@")"
}

search() { f="$(finder "$@")" && lf "$f"; unset f }
b()  { p="$(command bm "$@")" && cd "$p" || echo "$p"; unset p }
_b() { compadd $(command bm -l) }
compdef _b b
alias bm=b

# bindings
bindctrl() { bindkey -s "^$1" '\eddi '"${2}"'\n' }
bindctrl o lf
bindctrl f search
bindctrl n b

# basic stuff
alias mk='mkdir -pv'
alias cp='cp -iv'
alias mv='mv -iv'

# start graphical env
alias startx='command startx "$XINITRC" -- "$XSERVERRC" vt1 -keeptty'

# display cheatsheets and bropages for commands from cheat.sh
cheat() { curl -Ss cheat.sh/"$@" | $PAGER }
alias bro='cheat'

# man-pages in vim
alias man='vman'
compdef vman=man

# sources
alias build='make clean; make; sudo make install; make clean'

# pacman
alias p='sudo pacman'
alias a='paru'
alias pl='paclast -t | head'

# vim
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
svi() { SUDO_COMMAND="sudoedit $1" sudoedit "$1" }

# speed
alias speed='speedtest-cli --bytes'

# git

# add my github ssh key to ssh agent, only if it isn't already added
alias gssh='ssh-add -l | grep -q "$(ssh-keygen -lf ~/.ssh/id_github)" || ssh-add ~/.ssh/id_github'
alias g='gssh; command git'
alias git=g
alias gs='g status'
alias gl='g log --oneline'
alias ga='g add'
alias gaa='g add -A'
alias gc='g commit'
alias gcm='g commit -m'
alias gl3='g -P log --oneline -n3'
alias gp='g push || figlet failed; gl3'
alias gpa='g remote | { xargs -L1 g push || figlet failed }; gl3'

# shellcheck
alias shch='shellcheck'

# pulseaudio load loopback module
alias linein='pactl load-module module-loopback latency_msec=5'
alias lineinu='pactl unload-module module-loopback'

# view system logs
alias logview='less /var/log/everything.log '
alias loglive='tail -n 20 -f /var/log/everything.log'

# fc-font aliases
alias font-cache='fc-cache -r -v'
font-search() { fc-list | grep -i "$1" }

# dictionary
alias d=vimdict

# color diff
alias cdiff='diff --color=always'

# some info about python packages
alias pips='pip install --user'
alias pipusr='pip freeze --user | awk -F== "{print \$1}"'
alias pipsys='
    diff -y <(pip freeze --user) <(pip freeze) |
    awk "/>/{print \$2}" | awk -F== "{print \$1}"'

# watch cpu frequency in realtime
alias freq='watch -n1 grep \"cpu MHz\" /proc/cpuinfo'

# searching
alias sdot='search ~/.dots'
alias sd='search /mnt/drives/d'
alias sx='search /mnt/drives/x'
alias sy='search /mnt/drives/y'
alias sf='search /mnt/drives/d /mnt/drives/x'
alias sproj='search /mnt/drives/d/ehsan-files/Projects'
alias seh='search /mnt/drives/d/ehsan-files'
alias sdl='search /mnt/drives/d/downloads'
alias sfilm='search /mnt/drives/x/Film /mnt/drives/d/Film'

# run vim fugitive
alias fu='vim -c Git -c only'

# top
alias nettop='sudo nethogs'
alias iotop='sudo iotop'

# ripgrep
alias rip='rg -Luu'
alias ripz='rg -Luuz'
alias ripg='rg -L --hidden'

# windscribe
WindLoc='/tmp/WindscribeLocations'
alias vpnlu="windscribe locations > $WindLoc"
alias vpnl="
    test -r "$WindLoc" || vpnlu
    (grep -v '*' $WindLoc; grep '*' $WindLoc) | less
"

# protonvpn
alias pvpn='sudo protonvpn'

# edit aliases and such
alias shit='$EDITOR $XDG_CONFIG_HOME/zsh/aliases.zsh'
