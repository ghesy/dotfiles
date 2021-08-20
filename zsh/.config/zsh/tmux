# vim:ft=zsh
# start a new tmux session and window per terminal window,
# and kill the session and window when the terminal window closes.
[ -z "$TMUX" ] && [ -n "$DISPLAY" ] &&
{
    rand() { tr -dc 'a-z0-9' </dev/urandom | head -c20 }
    tsesh=$(rand)
    twndw=$(rand)

    kill() { tmux kill-session -t $1 \; killw -t $2 }
    trap "kill $tsesh $twndw" EXIT

    if [ "$(tmux ls 2>/dev/null | wc -l)" -lt 1 ]; then
        tmux new -s $tsesh -t main \; renamew $twndw
    else
        tmux new -s $tsesh -t main \; neww -n $twndw
    fi
}
