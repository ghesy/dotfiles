" open/close a terminal window with ctrl-b.

" bindings
nno <silent><C-b> :call OpenTerm()<CR>
nno <silent><C-t> :call KillTerm()<CR>
fu TermMaps()
    tno <silent><C-b> <C-\><C-n>:call GoBack()<CR>
    tno <silent><C-t> <C-\><C-n>:call KillTerm()<CR>
endf
fu TermUnMaps()
    tunmap <C-b>
    tunmap <C-t>
endf

" if terminal buffer exists, open it in a new window.
" otherwise, open a new terminal in a new window.
fu OpenTerm()
    if IsTerm(bufnr()) | call GoBack() | return | endif
    let g:PrevWinNr = winnr()
    call PrepWindow()
    if OpenPrevTerm() | return | endif
    term
    startinsert
    call setbufvar(bufnr(), "MyTerm", "true")
endf

" find open the existing terminal buffer.
fu OpenPrevTerm()
    for l:num in range(1, bufnr('$'))
        if !buflisted(l:num) | continue | endif
        if !IsTerm(l:num) | continue | endif
        exec "buffer" l:num
        startinsert
        return 1
    endfor
    return 0
endf

" go to the window prior to opening the terminal.
fu GoBack()
    if !IsTerm(bufnr())  | return | endif
    wincmd q
    call win_gotoid(win_getid(g:PrevWinNr))
endf

" find the open terminal buffer and kill it.
fu KillTerm()
    for l:num in range(1, bufnr('$'))
        if !buflisted(l:num) | continue | endif
        if !IsTerm(l:num) | continue | endif
        exec l:num . "bd!"
    endfor
endf

" open a new window and position it properly.
fu PrepWindow()
    vsplit
    wincmd l
    wincmd L
endf

" check wether the given buffer is a teminal that we opened.
fu IsTerm(bufnum)
    if getbufvar(a:bufnum, "MyTerm") == "true"
        return 1 | else | return 0 | endif
endf

" turn off line numbers and scrolloff upon
" entering terminal, revert upon leaving.
autocmd TermEnter * call TermEnter()
autocmd TermLeave * call TermLeave()

fu TermEnter()
    if !IsTerm(bufnr())  | return | endif
    let g:OrigS = &scrolloff
    let g:OrigN = &nu
    let g:OrigR = &rnu
    set nonu nornu scrolloff=0
    call TermMaps()
endf

fu TermLeave()
    if !IsTerm(bufnr())  | return | endif
    if g:OrigN | setlocal nu  | endif
    if g:OrigR | setlocal rnu | endif
    exec "setlocal scrolloff=" . g:OrigS
    call TermUnMaps()
endf
