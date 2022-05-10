# the zoomer shell's config.

HISTSIZE=10000000
SAVEHIST=10000000
HISTFILE=~/.cache/zsh/history
[[ ! -d ${HISTFILE%/*} ]] && mkdir -pm700 ${HISTFILE%/*}
setopt sharehistory histreduceblanks histignoredups
setopt ignoreeof nullglob interactivecomments autocd

# shell prompt
autoload -U colors && colors
precmd_prompt() {
    local cwd branch host rc="%{$reset_color%}"
    cwd=${PWD/#$HOME/'~'}
    cwd=${${(j:/:)${(s:/:)cwd}[-3,$]}:-$cwd}
    [[ -d .git ]] && branch=$(command git branch --show-current 2>/dev/null)
    branch=${branch:+" on %{$fg[yellow]%}$branch$rc"}
    [[ -n $SSH_CONNECTION ]] && host=" at %{$fg[blue]%}%M$rc"
    PS1="%{$fg[cyan]%}%n$rc${host} in $cwd$branch"$'\n'"➜ "
}
precmd_functions+=(precmd_prompt)

# print a list of files on cd
chpwd_ls() {
    local ls=$(ls -AFCtxw$COLUMNS --color=always --group-directories-first)
    [[ ${#${(fA)ls}} -gt 3 ]] && ls=${(F)${(f)ls}[#,3]}'  ...'
    printf '%s\n' "$ls"
}
chpwd_functions+=(chpwd_ls)

# tab complete options
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' # make lowercase letters match uppercase letters as well
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} # use LS_COLORS to colorize names of files and dirs
zstyle ':completion:*' hosts '' # don't match against /etc/hosts entries
zstyle ':completion:*' file-sort modification
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*' list-rows-first true
_comp_options+=(globdots)
autoload -U compinit && compinit

# make tab complete the word AND list the choices
zle-complete-and-list() { zle complete-word && zle list-choices }
zle -N zle-complete-and-list
bindkey '\t' zle-complete-and-list

# ctrl+e: edit the current cmdline in the editor
autoload edit-command-line && zle -N edit-command-line
bindkey '^e' edit-command-line

# enable vi mode
bindkey -v '^?' backward-delete-char
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
preexec_cursor() { zle-line-init }
preexec_functions+=(preexec_cursor)

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
autoload -U surround
zle -N delete-surround surround && bindkey -a ds delete-surround
zle -N change-surround surround && bindkey -a cs change-surround
zle -N add-surround surround && bindkey -a ys add-surround
bindkey -M visual S add-surround

# add visited directories to freq on cd
chpwd_fre() { ( freq -a "$PWD" & ) }
chpwd_functions+=(chpwd_fre)

# add files and dir in the executed commands to freq
preexec_fre() {
    for arg in ${(Q)${(Z:C:)1}}; do
        [[ -e $arg ]] || arg=${(e)arg}
        [[ -e $arg ]] && freq -a "${arg:a}"
    done
}
preexec_functions+=(preexec_fre)

# source some useful fzf stuff
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

# source the aliases
source ~/.config/zsh/aliases.zsh
