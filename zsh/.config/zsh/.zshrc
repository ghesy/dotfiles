# the zoomer shell's config.

HISTSIZE=10000000
SAVEHIST=10000000
HISTFILE=~/.cache/zsh/history
[[ ! -d ${HISTFILE%/*} ]] && mkdir -pm700 ${HISTFILE%/*}
setopt sharehistory histreduceblanks histignoredups
setopt ignoreeof nullglob interactivecomments autocd

# shell prompt
autoload -U colors && colors
precmd() {
    local git cwd
    cwd=${PWD/#$HOME/'~'}
    cwd=${${(j:/:)${(A)${(s./.)cwd}}[-3,$]}:-$cwd}
    [[ -d .git ]] && git=$(command git branch --show-current 2>/dev/null)
    git=${git:+"%{$reset_color%}at %{$fg[yellow]%}$git"}
    PS1="%{$fg[cyan]%}%n %{$reset_color%}in $cwd $git%{$reset_color%}"$'\n'"➜ "
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

# ctrl+e: edit the current cmdline in the editor
autoload edit-command-line && zle -N edit-command-line
bindkey '^e' edit-command-line

# navigate the tab-completion menu using vi keys
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# enable vi mode
bindkey -v
KEYTIMEOUT=1

# change the cursor shape in different vi modes
zle -N zle-keymap-select
zle-keymap-select() {
    case $KEYMAP in
        vicmd) echo -ne '\e[1 q';; # block
        viins|main) echo -ne '\e[5 q';; # beam
    esac
}
zle -N zle-line-init
zle-line-init() { echo -ne '\e[5 q' }
preexec() { zle-line-init }

# add bracket and quote pair support to zsh's vi mode
# this adds the "ciX", "caX", "diX", etc. bindings
# from /usr/share/zsh/functions/Zle/select-{bracketed,quoted}
autoload -U select-bracketed && zle -N select-bracketed
autoload -U select-quoted && zle -N select-quoted
() { local mode char
for mode in visual viopp; do
    for char in {a,i}${(s..)^:-'()[]{}<>bB'}; do
        bindkey -M $mode $char select-bracketed
    done
    for char in {a,i}{\',\",\`}; do
        bindkey -M $mode $char select-quoted
    done
done }

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

# source fzf's ctrl+r and ctrl+t functions
source /usr/share/fzf/key-bindings.zsh

# source the aliases
source ~/.config/zsh/aliases.zsh
