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

# other settings
setopt ignoreeof # don't exit by ctrl-d
setopt autocd # cd to paths typed in the shell, without the cd command
setopt globdots # glob dotfiles as well
setopt nullglob # make globs expand to nothing if they match nothing
setopt interactivecomments # allow comments in interactive shell
stty stop undef # disable ctrl-s freezing the shell

# tab complete options
autoload -U compinit
zstyle ':completion:*' completer _complete _ignored _correct _approximate
zstyle ':completion:*' max-errors 2
zstyle ':completion:*' menu select
zstyle ':completion:*' hosts ''
zstyle ':completion:*' matcher-list '' \
'm:{[:lower:]}={[:upper:]}' \
'm:{[:lower:][:upper:]}={[:upper:][:lower:]} r:|[._-]=** r:|=**' \
'm:{[:lower:][:upper:]}={[:upper:][:lower:]} r:|[._-]=** r:|=** l:|=*'
zmodload zsh/complist
compinit
_comp_options+=(globdots)

# edit current line in vim with ctrl-e:
autoload edit-command-line
zle -N edit-command-line
bindkey '^e' edit-command-line

# vi mode
bindkey -v
export KEYTIMEOUT=1

# use vim keys in tab complete menu
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# change cursor shape for different vi modes
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
# initiate `vi insert` as keymap
# (can be removed if `bindkey -V` has been set elsewhere)
zle-line-init() {
    zle -K viins
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# load aliases
al=~/.config/zsh/aliases.zsh
[ -r "$al" ] && source "$al"
unset al

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

# enable fast-syntax-highlighting plugin
#source /usr/share/zsh/plugins/fast-syntax-highlighting/*.zsh
# unbold the red color in syntax highlighting
#FAST_HIGHLIGHT_STYLES[${FAST_THEME_NAME}unknown-token]='fg=red'

# source pywal colors
seq=~/.cache/wal/sequences
fzf=~/.cache/wal/fzf
[ -r "$seq" ] && ( sed 's/\[[0-9]\{1,3\}\]//g' ~/.cache/wal/sequences & )
[ -r "$fzf" ] && source ~/.cache/wal/fzf 2>/dev/null
unset seq fzf

# clear terminal on graphical terminal initialization
[ -z "$TERMINIT" ] && [ -n "$DISPLAY" ] && clear
export TERMINIT=true;
