# return if already in tmux or the shell isn't interactive
[ -n "$TMUX" ] || [[ $- != *i* ]] || ! which tmux >/dev/null && return

# else, start a vanilla tmux session if it's an ssh connection
[ -n "$SSH_CONNECTION" ] && exec tmux new -Asssh

# else, start a new tmux session and window per terminal window,
# and kill the session and window when the terminal window closes.
# this practically eliminates tmux's session management,
# so we can only use it's scollback buffer without any intrusion.
[ -n "$DISPLAY" ] && {
    conf=~/.config/zsh/tmux.conf
    tsesh=$$$RANDOM
    twndw=$$$RANDOM
    trap "tmux kill-session -t $tsesh \; killw -t $twndw" EXIT
    if [ "$(tmux ls 2>/dev/null | wc -l)" -lt 1 ]; then
        tmux -f $conf new -s $tsesh -t main \; renamew $twndw
    else
        tmux -f $conf new -s $tsesh -t main \; neww -n $twndw
    fi
}
