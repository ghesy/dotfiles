set statusline=
set statusline+=%f
set statusline+=%r
set statusline+=%m
set statusline+=%{b:gitbranch}
set statusline+=%=
set statusline+=%l
set statusline+=:
set statusline+=%c
set statusline+=\ %P
set statusline+=\ %{&ft}

function! StatuslineGitBranch()
  let b:gitbranch=""
  if &modifiable
    try
      let l:dir=expand('%:p:h')
      let l:gitrevparse = system("git -C ".l:dir." branch --show-current")
      if !v:shell_error
        let b:gitbranch=" | ".substitute(l:gitrevparse, '\n', '', 'g')
      endif
    catch
    endtry
  endif
endf

augroup GetGitBranch
  autocmd!
  autocmd VimEnter,WinEnter,BufEnter * call StatuslineGitBranch()
augroup END
