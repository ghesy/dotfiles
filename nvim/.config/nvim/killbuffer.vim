" a couple of functions for closing buffers withous messing with splits.
" KillBuffer() and OnlyBuffer().

" delete the current buffer without fucking with open splits
function! KillBuffer()
    " if it's an unlisted buffer (fzf, nerdtree, undotree, ...),
    " or it's a coc diag window, wipe it.
    if ( buflisted(bufnr('%')) == 0  ||
       \ IsCurrentBufferCocDiag()    ||
       \ IsCurrentBufferFugitive() )
        bw
    " if there are more than one listed buffers:
    elseif len(getbufinfo({'buflisted':1})) != 1
        " if the buffer is open in more than one window:
        if len(win_findbuf(bufnr('%'))) != 1
            " switch all the other windows/splits that have that buffer
            " to other buffers, so that the windows/splits don't get closed
            let l:orig_winid = win_getid()
            for l:winid in win_findbuf(bufnr('%'))
                if ( l:winid == l:orig_winid ) | continue | endif
                call win_gotoid(l:winid)
                bprev
            endfor
            call win_gotoid(l:orig_winid)
        endif
        " kill the buffer (after switching to another buffer so that
        " the window doesn't get closed)
        bprev
        if ( &buftype == "terminal" ) | bw! # | else | silent! bd # | endif
    endif
endf


" KillBuffer all buffers except the active one.
function! OnlyBuffer()
    if (exists(':UndotreeHide') != 0)
        UndotreeHide
    endif
    if (IsCurrentBufferFugitive())
        edit _TemporaryBuffer
        silent! call OnlyBuffer()
        Git
        bw _TemporaryBuffer
        return
    endif
    let l:orig_buffnum = bufnr('%')
    " for l:buffnum in (filter(range(1, bufnr('$')), 'bufloaded(v:val)'))
    for l:buffnum in range(1, bufnr('$'))
        if ( l:buffnum == l:orig_buffnum ) | continue | endif
        if ( getbufinfo(l:buffnum)[0].changed == 1 ) | continue | endif
        exec ":buffer" l:buffnum
        call KillBuffer()
    endfor
endf


function! IsCurrentBufferCocDiag()
    if ( buffer_name('%') == '' && &syntax == 'qf' )
        return 1
    else
        return 0
    endif
endf


function! IsCurrentBufferFugitive()
    if ( &syntax == 'fugitive' )
        return 1
    else
        return 0
    endif
endf
