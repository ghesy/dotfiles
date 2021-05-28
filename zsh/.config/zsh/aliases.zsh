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
    case "$1" in
        -remote|-doc|-version|-server) command lf "$@" ;;
        *) lfrun "$@"; cd "$(lflast)" ;;
    esac
}

finder() { local xx="$(command finder "$@")"; [ -n "$xx" ] && lf "$xx" }
g() { cd "$(bm "$@")" }

# bindings
bindctrl() { bindkey -s "^$1" '\eddi '"${2}"'\n' }
bindctrl u 'setsid -f $TERMINAL > /dev/null 2>&1 \n'
bindctrl o lf
bindctrl f finder
bindctrl n g

# basic stuff
alias clear='sl'
alias mk='mkdir -pv'
alias cp='cp -iv'
alias mv='mv -iv'

# run startx and shut it the fuck up
alias startx='/usr/bin/startx "${XDG_CONFIG_HOME}/X11/xinitrc"'
alias startxq='startx >/dev/null 2>&1'

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
alias pls='paclast -r | head'

# vim
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias svi='sudoedit'

# speed
alias speed='speedtest-cli --bytes'

# git
alias G=git
alias gits='git status'
alias gitl='git log --oneline'
alias gita='git add'
alias gitaa='git add -A'
alias gitc='git commit'
alias gitcm='git commit -m'
alias gitl3='git -P log --oneline -n3'
alias gitssh='
ssh-add -l | grep -q "$(ssh-keygen -lf ~/.ssh/id_github)" ||
    ssh-add ~/.ssh/id_github'
alias gitp='gitssh; git push || figlet failed; gitl3'
alias gitpa='gitssh; git remote | { xargs -L1 git push --all || figlet failed }; gitl3'

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
d()
{
    d="$(command dict "$@")"
    [ $? -ne 0 ] && return 1
    echo "$d" | colorit -c ~/.config/colorit/colorit.conf | $PAGER
}

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
alias sdot='finder ~/.dots'
alias sc='finder ~/.local/bin ~/.config ~/Repositories ~/.local/sv'
alias sd='finder /mnt/drives/d'
alias sx='finder /mnt/drives/x'
alias sy='finder /mnt/drives/y'
alias sf='finder /mnt/drives/d /mnt/drives/x'
alias sproj='finder /mnt/drives/d/ehsan-files/Projects'
alias seh='finder /mnt/drives/d/ehsan-files'
alias sdl='finder /mnt/drives/d/downloads'
alias sfilm='finder /mnt/drives/x/Film /mnt/drives/d/Film'

# run vim fugitive
alias fugitive='vim -c Git -c only'
alias gs='fugitive'

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
