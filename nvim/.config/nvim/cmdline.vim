" show percentage and buffers on cmdline.

set noruler noshowcmd

function Percent()
    let above = line('w0') - 1
    let below = line('$') - line('w$')
    if below <= 0
        return above ? 'Bot' : 'All'
    elseif above <= 0
        return 'Top'
    else
        return printf('%2d%%', above > 1000000 ?
            \ above / ((above + below) / 100) :
            \ above * 100 / (above + below))
    endif
endf

let g:bufferline_echo = 0
let g:bufferline_fixed_index =  0
let g:bufferline_show_bufnr = 0
let g:bufferline_rotate = 0

function UpdateBuffers()
    let g:CmdBuffers = ""
    if buflisted(bufnr('%')) == 0 | return | endif
    let l:buffers = bufferline#get_echo_string()
    if l:buffers == "[ ]" | return | endif
    let g:CmdBuffers = l:buffers
    let g:bufferline_show_bufnr = 0
    let g:bufferline_rotate = 0
endf

function CmdLineMain()
    let l:leave_end = 5
    let l:percent = Percent()
    if g:CmdBuffers == "" | let l:percent = "" | endif
    exec ":let l:line = l:percent . ' ' . g:CmdBuffers"
    if len(l:line) > &columns - l:leave_end - 1
        let g:bufferline_show_bufnr = 1
        let g:bufferline_rotate = 1
        call UpdateBuffers()
        exec ":let l:line = l:line[:" &columns - l:leave_end "] . '...'"
    endif
    echo l:line
endf

function CmdLine()
    call timer_start(1, {-> execute('call CmdLineMain()', '')})
endf

autocmd CursorHold,CursorMoved,VimResized * call CmdLine()
autocmd BufWinEnter,WinEnter,BufDelete,BufWipeout,BufWritePost,
\InsertLeave,CursorHoldI * call UpdateBuffers() | call CmdLine()

nn <silent><Esc> :call UpdateBuffers()<BAR>call CmdLine()<CR><Esc>
nn <silent>u u:call UpdateBuffers()<BAR>call CmdLine()<CR>
nn <silent><C-r> <C-r>:call UpdateBuffers()<BAR>call CmdLine()<CR>
