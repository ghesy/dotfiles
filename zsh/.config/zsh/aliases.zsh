# zsh's aliases, functions and bindings.

# add fzf's ctrl-r and ctrl-t functions
source /usr/share/fzf/key-bindings.zsh

alias ls='command ls -AF --color=always --group-directories-first'

lf() {
    pgrep -xs0 lf >/dev/null && exit
    local tmp="$(mktemp)"
    command lf -last-dir-path="$tmp" "$@"
    [ ! -f "$tmp" ] && return
    local dir="$(cat "$tmp")"
    rm -f "$tmp"
    [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
}

search() {
    F="$(finder "$@")" || return 1
    if [[ "$(basename -- "$F")" == .* ]]; then
        lf -command 'set hidden' -- "$F"
    else
        lf -- "$F"
    fi
    unset F
}

paru() {
    [ $# -eq 0 ] && sudo -v && artixnews
    command paru "$@"
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
alias cp='advcp -ig'
alias mv='advmv -ig'
alias rm='rm -Iv --one-file-system'

# man-pages in vim
alias man=vman
compdef vman=man

# pacman
alias p='sudo pacman'
alias pl='paclast -t | head'
alias pa=paru

# vim
alias v=nvim
alias vi=nvim
alias vim=nvim
svi() { SUDO_COMMAND="sudoedit $1" sudoedit "$1" }

# git
# add my github ssh key to ssh agent, only if it isn't already added
alias gssh='ssh-add -l | grep -q "$(ssh-keygen -lf ~/.ssh/github | cut -d\  -f2)" || ssh-add ~/.ssh/github'
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
alias logview='${PAGER:-less} /var/log/everything.log '
alias loglive='tail -n 20 -f /var/log/everything.log'
alias d=vimdict
alias sdl='search /media/downloads'
alias sf='search /media /mnt'
alias sd='search ~/.config ~/.local/bin ~/.dots ~/Documents/Notes ~/Repositories'
alias fu='git rev-parse --git-dir >/dev/null 2>&1 && vim -c Git -c only'
alias rg='rg -.Lg "!.git"'
alias pvpn='sudo protonvpn'
alias shit='$EDITOR $XDG_CONFIG_HOME/zsh/aliases.zsh'
alias downgrade='sudo downgrade --ala-url https://archive.artixlinux.org'
