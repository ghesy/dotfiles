# vim:ft=zsh
# start a new tmux session and window per terminal window,
# and kill the session and window when the terminal window closes.
[ -n "$TMUX" ] || [[ $- != *i* ]] && return
[ -n "$SSH_CONNECTION" ] && exec tmux new -Asssh
[ -n "$DISPLAY" ] &&
{
    tsesh=$$$RANDOM
    twndw=$$$RANDOM
    trap "tmux kill-session -t $tsesh \; killw -t $twndw" EXIT
    if [ "$(tmux ls 2>/dev/null | wc -l)" -lt 1 ]; then
        tmux new -s $tsesh -t main \; renamew $twndw
    else
        tmux new -s $tsesh -t main \; neww -n $twndw
    fi
}
