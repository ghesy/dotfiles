let mapleader = " "

" install vim-plug
if ! filereadable(system('echo -n "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim"'))
    echo "installing vim-plug..."
    silent !mkdir -p ${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload
    silent !sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    autocmd VimEnter * PlugInstall
endif

" enable truecolor
set termguicolors

" plugins
call plug#begin('~/.local/share/nvim/plugged')

Plug 'drmikehenry/vim-headerguard'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-commentary'
Plug 'justinmk/vim-sneak'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-eunuch'
Plug 'bling/vim-bufferline'
Plug 'pbrisbin/vim-colors-off'
Plug 'davidosomething/vim-colors-meh'
Plug 'sainnhe/gruvbox-material'
Plug 'mbbill/undotree', {'on':'UndotreeToggle'}
Plug 'junegunn/fzf', {'do': { -> fzf#install() }}
Plug 'junegunn/fzf.vim'
call plug#end()

" basics
set ignorecase
set smartcase
set hidden
set updatetime=700
set visualbell
set number
set relativenumber
set nowrap
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set list lcs=tab:\-\ "
set scrolloff=5
set sidescrolloff=10
set matchpairs+=<:>

" other
let g:netrw_dirhistmax = 0
set shortmess+=ac
set noswapfile
set undofile

" search for files natively in vim
set path+=**
set wildignore+=**/.git/**
set wildignore+=**/node_modules/**

" on save, deletes all trailing whitespace and newlines at end of file.
autocmd BufWritePre * %s/\s\+$//e
autocmd BufWritePre * %s/\n\+\%$//e

" open terminal in vim's pwd
nnoremap <silent>U :silent !termopen<CR>

" center the cursor horizontally
nnoremap <silent> z. :normal! zszH<CR>

" go to start/end of line
nnoremap H ^
nnoremap L $

" indent
nmap <C-h> vip<
nmap <C-l> vip>
vmap <C-h> <gv4h
vmap <C-l> >gv4l

" quick macro
nnoremap Q @q

" paste the last yanked text
noremap <Leader>p "0p
noremap <Leader>P "0P

" copy/paste
vnoremap <C-c> "+y
map <C-v> "+P

" clear search
nnoremap <silent><Leader>cs :let @/=''<CR>

" compile markdown
autocmd FileType markdown
  \ nnoremap <Leader>md :silent !mdpdf %:p:S<CR> |
  \ nnoremap <Leader>cc :silent !mdpdf -o %:p:S<CR>

" fugitive
nmap <Leader>gs :G<CR>
nmap <Leader>gt :Git log --oneline --graph --decorate --all <CR>

" diff
nmap <Leader>gh :diffget //2<CR>
nmap <Leader>gl :diffget //3<CR>
nmap <Leader>gg :diffget<CR>
nmap <Leader>gp :diffput<CR>

" fuzzy searching
nnoremap <Leader>ff :Files<CR>
nnoremap <Leader>FL :BLines<CR>
nnoremap <leader>fl :Lines<CR>
nnoremap <leader>rg :Rg<CR>
nnoremap <C-f> :Buffers<CR>

" splits and windows
nnoremap <silent><Leader>vs :vs<CR>
nnoremap <silent><Leader>sp :sp<CR>
nmap <silent><C-h> :wincmd h<CR>
nmap <silent><C-j> :wincmd j<CR>
nmap <silent><C-k> :wincmd k<CR>
nmap <silent><C-l> :wincmd l<CR>
nnoremap <silent><Leader>i :vertical resize +5<CR>
nnoremap <silent><Leader>d :vertical resize -5<CR>
nnoremap <silent><Leader>I :resize +5<CR>
nnoremap <silent><Leader>D :resize -5<CR>
nnoremap <silent><Leader>eq :wincmd =<CR>
nnoremap <silent><Leader>wq :wincmd q<CR>
nnoremap <silent><Leader>on :only<CR>
nnoremap <silent><Leader>ON :call OnlyBuffer()<CR>
nnoremap <silent><Leader>bw :call KillBuffer()<CR>
nnoremap <silent><Leader>bd :call KillBuffer()<CR>

" equalize window sizes upon vim resize
au VimResized * wincmd =

" search for visually selected text.
vno/remap <silent> // :<C-U>
  \ let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \ gvy/<C-R>=&ic?'\c':'\C'<CR><C-R><C-R>=substitute(
  \ escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \ gVzv:call setreg('"', old_reg, old_regtype)<CR>

" perform replace on visually-selected text
vnoremap <C-r> "hy:%s/<C-r><C-r>=escape(@h, '/\.*$^~[')<CR>
  \//gc<left><left><left>

" recognise double-slash cpp-style comments in json files
autocmd FileType json syntax match Comment +\/\/.\+$+

" move between buffers
function BufferNavigationMaps()
    nnoremap <silent> <C-n>   :bnext<CR>
    nnoremap <silent> <C-p>   :bprev<CR>
endf
call BufferNavigationMaps()

" undotree
nnoremap <silent><Leader>ut :call UndoTreeRun()<CR>
autocmd BufEnter * call FixBufferNavigationMaps()

function UndoTreeRun()
    if buflisted(bufnr('%'))
        UndotreeToggle
        UndotreeFocus
    else
        UndotreeHide
    endif
    call FixBufferNavigationMaps()
endf

function FixBufferNavigationMaps()
    if ( bufname('%') =~# "undotree_" || bufname('%') =~# "diffpanel_" )
        silent! nunmap <C-n>
        silent! nunmap <C-p>
    else
        call BufferNavigationMaps()
    endif
endf

" reload file if changed
autocmd FocusGained,CursorHold,CursorHoldI *
  \ if !bufexists("[Command Line]") | silent checktime | endif

" colors and appearance
let g:gruvbox_material_enable_italic = 1
let g:gruvbox_material_better_performance = 1
let g:gruvbox_material_disable_italic_comment = 0
colorscheme off

" set a constant horizontal line between splits
let g:HorizLine1='─'
let g:HorizLine2=''
function FillStatus()
    return repeat(g:HorizLine1, winwidth('%'))
endf
set statusline=%{FillStatus()}
exec "set fillchars=stlnc:" . HorizLine1 . ",stl:" . HorizLine2

function FixColors()
    hi StatusLine guifg=#505050 ctermfg=darkgrey ctermbg=NONE guibg=NONE
    hi StatusLineNC guifg=#505050 ctermfg=darkgrey ctermbg=NONE guibg=NONE
    hi VertSplit guifg=#505050 ctermfg=darkgrey ctermbg=NONE guibg=NONE
    hi EndOfBuffer guifg=#404040 ctermfg=darkgrey guibg=NONE ctermbg=NONE
    hi Normal guibg=NONE ctermbg=NONE
    hi LineNr guibg=NONE ctermbg=NONE
    hi CursorLineNr guibg=NONE ctermbg=NONE
    hi SignColumn guibg=NONE ctermbg=NONE
endf
autocmd ColorScheme * call FixColors()
call FixColors()

" load other configs
source ~/.config/nvim/killbuffer.vim
source ~/.config/nvim/term.vim
source ~/.config/nvim/cmdline.vim
