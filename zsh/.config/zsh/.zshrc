# the zoomer shell's config.

HISTSIZE=1000000
SAVEHIST=1000000
HISTFILE=~/.cache/zsh/history
mkdir -p $(dirname $HISTFILE)
setopt HIST_IGNORE_SPACE # don't put commands starting with space into history
setopt HIST_IGNORE_DUPS # don't put duplicate commands into history
setopt ignoreeof # don't exit by ctrl-d
setopt autocd # cd to paths typed in the shell, without the cd command
setopt globdots # glob dotfiles as well
setopt nullglob # make globs expand to nothing if they match nothing

# ==============================================
# ==============================================

# path for zcompdump
zcompdump="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/dump/zcompdump"
mkdir -p "$(dirname "$zcompdump")"

# The following lines were added by compinstall
zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' file-sort modification
zstyle ':completion:*' insert-unambiguous false
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' \
'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' \
'm:{[:lower:][:upper:]}={[:upper:][:lower:]} r:|[._-]=** r:|=**' \
'm:{[:lower:][:upper:]}={[:upper:][:lower:]} r:|[._-]=** r:|=** l:|=*'
zstyle ':completion:*' max-errors 2
zstyle ':completion:*' menu select=1
zstyle ':completion:*' original true
zstyle ':completion:*' select-prompt %SScrlling active: current selection at %p%s
zstyle ':completion:*' verbose true
zstyle :compinstall filename "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/.zshrc"
autoload -Uz compinit
compinit -d "$zcompdump"
_comp_options+=(globdots)
# End of lines added by compinstall
# Load complist
zmodload zsh/complist

# ==============================================
# ==============================================

# vi mode
bindkey -v
export KEYTIMEOUT=1

# use vim keys in tab complete menu:
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
zle-line-init() {
    # initiate `vi insert` as keymap
    # (can be removed if `bindkey -V` has been set elsewhere)
    zle -K viins
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# edit current line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

# load aliases
aliasesfile="$XDG_CONFIG_HOME/zsh/aliases.zsh"
test -r "$aliasesfile" && source "$aliasesfile"

# shell prompt
autoload -U colors && colors
precmd () {
    local wd="${PWD/#$HOME/~}"
    local depth=$(echo "$wd" | tr '/' '\n' | wc -l)
    [ "$depth" -ge 3 ] && local wd="$(echo "$wd" | rev | cut -d'/' -f1-3 | rev)"
    local git="$(git branch --show-current 2>/dev/null)"
    [ -n "$git" ] && git="at $git"
    newline () { printf "\n➜ " }
    PS1="%n in $wd $git$(newline)"
    unfunction newline
}
stty stop undef # disable ctrl-s to freeze terminal.

# enable fast-syntax-highlighting plugin
source /usr/share/zsh/plugins/fast-syntax-highlighting/*.zsh
# unbold the red color in syntax highlighting
FAST_HIGHLIGHT_STYLES[${FAST_THEME_NAME}unknown-token]='fg=red'

clear
