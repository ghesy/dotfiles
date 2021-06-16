nnoremap <silent><Leader>tt :term<CR>:startinsert<CR>
nnoremap <silent><Leader>tb :call BottomTerminal()<CR>

" spawn a bottom terminal
function BottomTerminal()
    split
    wincmd w
    wincmd J
    resize 10
    terminal
    call setbufvar(bufnr('%'), "IsBottomTerminal", "true")
    startinsert
endf

function FixBottomTerminalSize()
    if getbufvar(bufnr('%'), "IsBottomTerminal") == "true"
        resize 10
    endif
endf

autocmd BufEnter,BufWinEnter,WinEnter term://* silent! call FixBottomTerminalSize()

function TermEsc()
    if buflisted(bufnr('%')) == "1"
        tnoremap <silent><Esc> <C-\><C-n>
    else
        tnoremap <silent><Esc> <Esc>
    endif
endf

" fix scrolloff causing glitches in terminal
autocmd TermEnter * setlocal scrolloff=0 | setlocal nonumber |
  \ setlocal norelativenumber | silent! call TermEsc()

autocmd TermLeave * setlocal scrolloff=8 | setlocal number |
  \ setlocal relativenumber   | silent! call TermEsc()

autocmd BufEnter,BufWinEnter,WinEnter,BufLeave,BufWinLeave,WinLeave term://*
  \ silent! call TermEsc()
autocmd TermOpen * silent! call TermEsc()
