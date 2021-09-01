# zsh's aliases, functions and bindings.

# add fzf's ctrl-r and ctrl-t functions
source /usr/share/fzf/key-bindings.zsh

alias ls='command ls -AF --color=always --group-directories-first'

lf() {
    local tmp="$(mktemp)"
    lfrun -last-dir-path="$tmp" "$@"
    [ ! -f "$tmp" ] && return
    local dir="$(cat "$tmp")"
    rm -f "$tmp"
    [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
}

search() {
    local f="$(finder "$@")" || return 1
    if [[ "$(basename -- "$f")" == .* ]]; then
        lf -command 'set hidden' -- "$f"
    else
        lf -- "$f"
    fi
}

# bookmarks
b() {
    case "$1" in
        --) shift ;;
        -*) command bm "$@"; return ;;
    esac

    local p="$(command bm "$@")"
    [ -z "$p" ] && return
    cd "$p"
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
alias gssh='ssh-add -l | grep -q "$(ssh-keygen -lf ~/.ssh/github)" || ssh-add ~/.ssh/github'
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
alias fu='git rev-parse --git-dir >/dev/null 2>&1 && vim -c Git -c only'
alias rg='rg -.Lg "!.git/*"'
alias pvpn='sudo protonvpn'
alias shit='$EDITOR $XDG_CONFIG_HOME/zsh/aliases.zsh'
alias cp='cpg -ag --backup=numbered'
alias mv='mvg -g --backup=numbered'
