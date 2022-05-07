# custom commands aliases for zsh.

rmcmd() {
    repeat ${#${(f)PS1}} { echo -ne '\e[A\e[2K' }
}

lf() {
    [[ $1 = -s ]] && shift || rmcmd
    [[ -n $LF_LEVEL ]] && exit
    local tmp
    tmp=$(mktemp) || return
    command lf -last-dir-path="$tmp" "$@"
    [[ -f $tmp ]] || return
    local dir=$(<"$tmp")
    rm -f "$tmp"
    [[ -d $dir ]] && [[ $dir != $PWD ]] && cd "$dir"
}

search() {
    rmcmd
    local f
    f=$(finder "$@") || return
    if [[ ${f##*/} == .* ]]; then
        lf -s -command 'set hidden' -- "$f"
    else
        lf -s -- "$f"
    fi
}

paru() {
    [[ $# -eq 0 ]] && sudo -v && artixnews
    command paru "$@"
}

f() {
    rmcmd
    local p
    p=$(freq -m fzf) || return 1
    p=${p/#'~'/"$HOME"}
    [ -f "$p" ] && p=${p%/*}
    cd "$p"
}

h() {
    [[ $# -eq 1 ]] && set -- "$1" --help
    "$@" | ifne ${PAGER:-less}
}

# bindings
bindctrl() { bindkey -s "^$1" '\eddi '"$2"'\n' }
bindctrl o lf
bindctrl f search

# basic stuff
alias ls='command ls -AF --color=always --group-directories-first'
alias mk='mkdir -pv'
alias cp='advcp -ig'
alias mv='advmv -ig'
alias rm='rm -Iv --one-file-system'

# pacman
alias p='paru'
alias P='pacman'
alias pl='paclast -t | head'

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

# atool
aunpack='command aunpack -De'
apack() {
    local name=$1; shift
    apack "$name" ${(f)$(realpath -s --relative-base="$PWD" -- "$@")}
}

# other
alias startx='command startx "$XINITRC"'
alias speed='speedtest-cli --bytes'
alias shch='shellcheck'
alias logview='${PAGER:-less} /var/log/everything.log '
alias loglive='tail -n 20 -f /var/log/everything.log'
alias sdl='search /media/downloads'
alias sf='search /media /mnt'
alias sd='search ~/.config ~/.local/bin ~/.dots ~/Documents/Notes ~/Repositories'
alias fu='git rev-parse --git-dir >/dev/null 2>&1 && vim -c Git -c only'
alias rg='rg -.Lg "!.git"'
alias pvpn='sudo protonvpn'
alias shit='$EDITOR ~/.config/zsh/aliases.zsh'
alias downgrade='sudo downgrade --ala-url https://archive.artixlinux.org'
alias pxy='proxychains'
