# the zoomer shell's config.

# history settings
HISTSIZE=10000000
SAVEHIST=10000000
HISTFILE=~/.cache/zsh/history
mkdir -p $(dirname $HISTFILE)
setopt sharehistory # share history between all sessions
setopt histreduceblanks # remove superfluous blanks from history
setopt histignorespace # don't put commands starting with space into history
setopt histignoredups # don't put duplicate commands into history

# start tmux
source ~/.config/zsh/tmux.zsh

# other settings
setopt ignoreeof # don't exit by ctrl-d
setopt autocd # cd to paths typed in the shell, without the cd command
setopt nullglob # make globs expand to nothing if they match nothing
setopt interactivecomments # allow comments in interactive shell
stty stop undef # disable ctrl-s freezing the shell

# shell prompt
autoload -U colors && colors
precmd() {
    c() { printf %s "%{$fg[$1]%}" }
    local r="%{$reset_color%}"
    local wd="$(echo "${PWD/#$HOME/~}" | rev | cut -d'/' -f1-3 | rev)"
    local git="$(command git branch --show-current 2>/dev/null)"
    [ -n "$git" ] && git="${r}at $(c yellow)$git"
    PS1="$(c cyan)%n ${r}in $wd $git$r$(printf "\n➜ ")"
    unfunction c
}

# tab complete options
autoload -U compinit
zstyle ':completion:*' completer _complete _ignored _correct _approximate
zstyle ':completion:*' max-errors 2
zstyle ':completion:*' menu select
zstyle ':completion:*' hosts ''
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' \
    'm:{a-zA-Z}={A-Za-z} r:|[._-]=** r:|=**' \
    'm:{a-zA-Z}={A-Za-z} r:|[._-]=** r:|=** l:|=*'
zmodload zsh/complist && compinit
_comp_options+=(globdots)

# edit current line in vim with ctrl-e:
autoload edit-command-line
zle -N edit-command-line
bindkey '^e' edit-command-line

# vi mode
bindkey -v
export KEYTIMEOUT=1

# use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# change cursor shape for different vi modes.
function zle-keymap-select () {
    case $KEYMAP in
        vicmd) echo -ne '\e[1 q';;      # block
        viins|main) echo -ne '\e[5 q';; # beam
    esac
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # use beam shape cursor for each new prompt.

# add "ci" and "di" bindings for brackets to the vim mode
# from /usr/share/zsh/functions/Zle/select-bracketed
autoload -U select-bracketed
zle -N select-bracketed
for m in visual viopp; do
    for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
        bindkey -M $m $c select-bracketed
    done
done

# add "ci" and "di" bindings for quotes to the vim mode
# from /usr/share/zsh/functions/Zle/select-quoted
autoload -U select-quoted
zle -N select-quoted
for m in visual viopp; do
    for c in {a,i}{\',\",\`}; do
        bindkey -M $m $c select-quoted
    done
done

# add surround bindings ("ys", "cs", "ds") to the vim mode
# from /usr/share/zsh/functions/Zle/surround
autoload -Uz surround
zle -N delete-surround surround
zle -N add-surround surround
zle -N change-surround surround
bindkey -a cs change-surround
bindkey -a ds delete-surround
bindkey -a ys add-surround
bindkey -M visual S add-surround

# source the aliases
source ~/.config/zsh/aliases.zsh
