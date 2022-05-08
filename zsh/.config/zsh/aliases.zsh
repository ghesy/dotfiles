# custom commands aliases for zsh.

# remove the called command from the terminal's output
rmcmd() {
    repeat ${#${(f)PS1}} { echo -ne '\e[A\e[2K' }
}

# search the filesystem using fzf
s() {
    rmcmd
    cd "$(finder "$@")"
}

# search frequent files using fzf
f() {
    rmcmd
    local p
    p=$(freq -m fzf) || return 1
    p=${p/#'~'/"$HOME"}
    [[ -f $p ]] && p=${p%/*}
    cd "$p"
}

# show the help message of the given program in the pager
h() {
    [[ $# -eq 1 ]] && set -- "$1" --help
    "$@" | ifne ${PAGER:-less}
}

paru() {
    [[ $# -eq 0 ]] && sudo -v && artixnews
    command paru "$@"
}

lf() {
    rmcmd
    [[ -n $LF_LEVEL ]] && exit
    local tmp
    tmp=$(mktemp) || return
    command lf -last-dir-path="$tmp" "$@"
    local dir=$(<"$tmp")
    rm "$tmp"
    [[ -d $dir ]] && cd "$dir"
}

# basic stuff
alias a='command ls -AFt --color=always --group-directories-first'
alias A='a -l'
alias t='tree -laFtrC --dirsfirst -L 2'
alias 1='t -L 1 -i --noreport'
alias md='mkdir -pv'
alias cp='advcp -ig'
alias mv='advmv -ig'
alias T='trash-put'
alias rm='rm -Iv --one-file-system'
alias v=nvim

# pacman
alias p='paru'
alias P='pacman'
alias pl='paclast -t | head'

# editor
sv() { SUDO_COMMAND="sudoedit $1" sudoedit "$1" }

# git
alias gssh='ssh-add ~/.ssh/keys/github'
alias g='git'

# atool
aunpack='command aunpack -De'
apack() {
    local name=$1; shift
    command apack "$name" ${(f)$(realpath -s --relative-base="$PWD" -- "$@")}
}

# other
alias startx='command startx "$XINITRC"'
alias speed='speedtest-cli --bytes'
alias shch='shellcheck'
alias logview='${PAGER:-less} /var/log/everything.log '
alias loglive='tail -n 20 -f /var/log/everything.log'
alias fu='git rev-parse --git-dir >/dev/null 2>&1 && vim -c Git -c only'
alias rg='rg -.Lg "!.git"'
alias pvpn='sudo protonvpn'
alias al='$EDITOR ~/.config/zsh/aliases.zsh'
alias downgrade='sudo downgrade --ala-url https://archive.artixlinux.org'
alias pxy='proxychains'
