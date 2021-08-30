# zsh's aliases, functions and bindings.

# add fzf's ctrl-r and ctrl-t functions
source /usr/share/fzf/key-bindings.zsh

alias ls='command ls -AF --color=always --group-directories-first'

search() {
    f="$(finder "$@")" && lf "$f"
    unset f
}

lf() {
    pgrep -xs0 lf >/dev/null && exit
    lfrun "$@"
    cd "$(lflast "$@")"
}

# bookmarks
b() {
    case "$1" in
        --) shift ;;
        -*) command bm "$@"; return ;;
    esac

    p="$(command bm "$@")"
    [ -z "$p" ] && return
    cd "$p"
    unset p
}
_b() {
    compadd $(command bm -l)
}
compdef _b b
alias bm=b

# bindings
bindctrl() { bindkey -s "^$1" '\eddi '"${2}"'\n' }
bindctrl o lf
bindctrl f search

# basic stuff
alias mk='mkdir -pv'
alias cp='cp -iv'
alias mv='mv -iv'

# display cheatsheets and bropages for commands from cheat.sh
cheat() { curl -Ss "cheat.sh/$1" | $PAGER }
alias bro='cheat'

# man-pages in vim
alias man='vman'
compdef vman=man

# pacman
alias p='sudo pacman'
alias a='paru'
alias pl='paclast -t | head'

# vim
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
svi() { SUDO_COMMAND="sudoedit $1" sudoedit "$1" }

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
gp() { g push "$@" && gl3 || figlet failed }

# other
alias startx='command startx "$XINITRC"'
alias speed='speedtest-cli --bytes'
alias shch='shellcheck'
alias logview='less /var/log/everything.log '
alias loglive='tail -n 20 -f /var/log/everything.log'
alias d=vimdict
alias sdl='search /media/downloads'
alias sf='search /mnt'
alias fu='vim -c Git -c only'
alias rg='rg -.Lg "!.git/*"'
alias pvpn='sudo protonvpn'
alias shit='$EDITOR $XDG_CONFIG_HOME/zsh/aliases.zsh'
alias cp='cpg -ag --backup=numbered'
alias mv='mvg -g --backup=numbered'
