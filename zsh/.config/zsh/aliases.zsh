# custom commands aliases for zsh.

# remove the called command from the terminal's output
rmcmd() {
    ((rmcmdstate)) && return
    rmcmdstate=1
    repeat "${#${(f)PS1}}" { echo -ne '\e[A\e[2K' }
}
precmd_rmcmd() { rmcmdstate=0 }
precmd_functions+=(precmd_rmcmd)

lf() {
    rmcmd
    local hidden
    [[ -n $LF_LEVEL ]] && exit
    [[ $1 == .* ]] && hidden=(-command 'set hidden')
    local tmp
    tmp=$(mktemp) || return
    command lf -last-dir-path="$tmp" ${hidden:+"$hidden[@]"} "$@"
    local dir=$(<"$tmp")
    rm "$tmp"
    [[ ${dir:A} != ${PWD:A} ]] && [[ -d $dir ]] && cd "$dir"
}

# search the filesystem
search() {
    rmcmd
    local p
    p=$(finder) && lf "$p"
}

# search frequent files
frequent() {
    rmcmd
    local p
    p=$(freq -m fzf) && lf "$p"
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

# rerun the last command and pipe to pager
P() {
    local cmd=${history[$((HISTCMD-1))]}
    [[ $cmd =~ '^rm |^T |^trash-put' ]] && return 1
    read -q "?$ $cmd | less"$'\n''execute [yn]? ' \
        && echo || { echo; return 1 }
    eval "$cmd | ${PAGER:-less}"
}

bindctrl() { bindkey -s "^$1" '\eddi '"$2"'\n' }
bindctrl n lf
bindctrl o frequent
bindctrl f search

# basic stuff
alias a='command ls -AFt --color=always --group-directories-first'
alias A='a -l'
alias l='a'
alias L='A'
alias t='tree -laFtrC --dirsfirst -L 2'
alias 1='t -L 1 -i --noreport'
alias md='mkdir -pv'
alias cp='advcp -ig'
alias mv='advmv -ig'
alias T='trash-put'
alias rm='rm -iv --one-file-system'
alias v='nvim'
alias vi='nvim'

# pacman
alias p='paru'
alias pl='paclast -t | head'

# editor
sv() { SUDO_COMMAND="sudoedit $1" sudoedit "$1" }

# git
alias gssh='ssh-add ~/.ssh/keys/github'
alias g='git'

# run vim-fugitive
alias fu='git rev-parse --git-dir >/dev/null 2>&1 && nvim -c Git -c only'

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
alias rg='rg -.Lg "!.git"'
alias pvpn='sudo protonvpn'
alias al='$EDITOR ~/.config/zsh/aliases.zsh'
alias downgrade='sudo downgrade --ala-url https://archive.artixlinux.org'
alias pxy='proxychains'
alias pacdiff='sudo DIFFPROG="nvim -d" DIFFSEARCHPATH="/etc /boot" pacdiff'
