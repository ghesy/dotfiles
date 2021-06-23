" show percentage and buffers on cmdline.
" requires the vim-bufferline plugin.

" check if vim-bufferline is installed
if &runtimepath !~ 'vim-bufferline'
     echoerr "cmdline.vim requires plugin vim-bufferline."
     finish
endif

" turn off statusline and all the junk and clutter
set noruler noshowcmd noshowmode laststatus=0

" vim-bufferline initial settings
let g:bufferline_echo = 0
let g:bufferline_fixed_index =  0
let g:bufferline_show_bufnr = 0
let g:bufferline_rotate = 0

" build and display the entire cmd line
function CmdLineMain()
    let l:leave_end = 5
    let l:percent = Percent()
    if g:BufferLine == "" | let l:percent = "" | endif
    exec "let l:line = l:percent . ' ' . g:BufferLine"
    if len(l:line) > &columns - l:leave_end - 1
        let g:bufferline_show_bufnr = 1
        let g:bufferline_rotate = 1
        call BuffersMain()
        exec "let l:line = l:percent . ' ' . g:BufferLine"
        exec "let l:line = l:line[:" &columns - l:leave_end "] . '...'"
    endif
    hi CmdLineColor guifg=#598052 ctermfg=darkgreen
    echohl CmdLineColor
    echon l:line
    echohl None
endf

" generate the bufferline and put it
" in a global variable
function BuffersMain()
    let g:BufferLine = ""
    if buflisted(bufnr('%')) == 0 | return | endif
    let l:buffers = bufferline#get_echo_string()
    if l:buffers == "[ ]" | return | endif
    let g:BufferLine = GitBranch() . l:buffers
    let g:bufferline_show_bufnr = 0
    let g:bufferline_rotate = 0
endf

" generate a column number and
" a percentage through the file
function Percent()
    let above = line('w0') - 1
    let below = line('$') - line('w$')
    if below <= 0
        let l:p = above ? 'Bot' : 'All'
    elseif above <= 0
        let l:p = 'Top'
    else
        let l:p = printf('%2d%%', above > 1000000 ?
            \ above / ((above + below) / 100) :
            \ above * 100 / (above + below))
    endif
    return printf('%3d %s', getcurpos()[2], l:p)
endf

" get git branch of the buffer.
function GitBranch()
    if &modifiable | try
        let l:dir = expand('%:p:h')
        let l:git = system("git -C " . l:dir . " branch --show-current")
        if !v:shell_error
            return substitute(l:git, '\n', '', 'g') . " "
        endif
    catch | endtry | endif
    return ""
endf

" run CmdLineMain() in background
function UpdateCmdLine()
    call timer_start(1, {-> execute('call CmdLineMain()', '')})
endf

" run BuffersMain() and CmdLineMain() in background
function UpdateBuffers(...)
    if a:0 == 1 | let l:time = a:1 | else | let l:time = 5 | endif
    call timer_start(1, {-> execute('call BuffersMain()', '')})
    call timer_start(l:time, {-> execute('call CmdLineMain()', '')})
endf

" events that trigger a cmdline update
autocmd CursorHold,CursorMoved,VimResized * call UpdateCmdLine()
autocmd BufWritePost * call UpdateBuffers(&updatetime)
autocmd BufWinEnter,WinEnter,BufDelete,BufWipeout,InsertLeave,CursorHoldI *
  \ call UpdateBuffers()

" keypresses that trigger a cmdline update
nn <silent>u u:call UpdateBuffers()<CR>
nn <silent><C-r> <C-r>:call UpdateBuffers()<CR>
