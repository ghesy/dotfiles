" show percentage and buffers on cmdline.
" requires the vim-bufferline plugin.

" color and style
function CmdLineColor()
    hi CmdLineColor guifg=darkcyan ctermfg=darkcyan gui=bold cterm=bold
endf

" check if vim-bufferline is installed
if &runtimepath !~ 'vim-bufferline'
     echoerr "cmdline.vim requires plugin vim-bufferline."
     finish
endif

" turn off statusline and all the junk and clutter
set ruler showcmd noshowmode laststatus=0

" vim-bufferline initial settings
let g:bufferline_echo = 0
let g:bufferline_fixed_index =  0
let g:bufferline_show_bufnr = 0
let g:bufferline_rotate = 0

" build and display the entire cmd line
function CmdLineMain()
    let l:leave_end = 35
    if len(g:BufferLine) > &columns - l:leave_end - 1
        let g:bufferline_show_bufnr = 1
        let g:bufferline_rotate = 1
        call BuffersMain()
        exec "let g:BufferLine = g:BufferLine[:" &columns - l:leave_end "] . '...'"
    endif
    call CmdLineColor()
    echohl CmdLineColor
    echon g:BufferLine
    echohl None
endf

" generate the bufferline and put it
" in a global variable
function BuffersMain()
    if buflisted(bufnr('%')) == 0 | return | endif
    let g:BufferLine = bufferline#get_echo_string()
    if  g:BufferLine == "[ ]" | return | endif
    let g:bufferline_show_bufnr = 0
    let g:bufferline_rotate = 0
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
autocmd VimResized * call UpdateCmdLine()
autocmd BufWritePost * call UpdateBuffers(&updatetime)
autocmd BufWinEnter,WinEnter,BufDelete,BufWipeout,InsertLeave,
   \CursorHold,CursorHoldI * call UpdateBuffers()

" keypresses that trigger a cmdline update
nn <silent>u u:call UpdateBuffers()<CR>
nn <silent><C-r> <C-r>:call UpdateBuffers()<CR>
