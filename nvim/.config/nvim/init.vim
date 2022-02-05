let mapleader = " "

" install vim-plug
let s:VimPlugPath = '${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim'
let s:VimPlugURL = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
if ! filereadable(system('printf '.s:VimPlugPath))
    echo 'Installing vim-plug...'
    call system('curl --create-dirs -fsLo '.s:VimPlugPath.' '.s:VimPlugURL)
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
Plug 'chaoren/vim-wordmotion'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-eunuch'
Plug 'bling/vim-bufferline'
Plug 'mbbill/undotree', {'on':'UndotreeToggle'}
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-repeat'
" colorschemes
Plug 'sainnhe/everforest'
Plug 'pbrisbin/vim-colors-off'
Plug 'arcticicestudio/nord-vim'
Plug 'sainnhe/gruvbox-material'
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
set laststatus=0
set noshowmode
set noruler
set mouse=a

" other
let g:netrw_dirhistmax = 0
set shortmess+=ac
set noswapfile
set undofile

" on save, deletes all trailing whitespace and newlines at end of file.
function s:NoTrailing()
    " if the file is binary, don't do anything
    if !!search('\%u0000', 'wn') | return | endif
    let line = line(".")
    let col = col(".")
    %s/\s\+$//e
    %s/\n\+\%$//e
    call cursor(line, col)
endf
autocmd BufWritePre * call <SID>NoTrailing()

" open a terminal in vim's pwd
nnoremap <silent>U :silent !termopen<CR>

" center the cursor horizontally
nnoremap <silent> z. zs5zh

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
nnoremap <silent><Leader>cs :nohlsearch<CR>

" compile markdown
function MarkdownMaps()
    nnoremap <Leader>cc :!pandoc -s --pdf-engine=wkhtmltopdf -o %:r:S.pdf %:S<CR>
    nnoremap <Leader>vv :silent !setsid -f zathura %:r:S.pdf<CR>
endf
autocmd FileType markdown call MarkdownMaps()

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
nnoremap <leader>fl :Lines<CR>
nnoremap <Leader>FL :BLines<CR>
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

" equalize window sizes upon vim resize
au VimResized * wincmd =

" search for the visually selected text
vnoremap <silent> // :<C-U>
  \ let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \ gvy/<C-R>=&ic?'\c':'\C'<CR><C-R><C-R>=substitute(
  \ escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \ gVzv:call setreg('"', old_reg, old_regtype)<CR>

" perform replace on visually-selected text
vnoremap <C-r> "hy:%s/<C-r><C-r>=escape(@h, '/\.*$^~[')<CR>
  \//gc<left><left><left>

" recognise double-slash cpp-style comments in json files
autocmd FileType json syntax match Comment +\/\/.\+$+

" undotree
nnoremap <silent><Leader>ut :call UndoTreeRun()<CR>
function UndoTreeRun()
    if buflisted(bufnr('%'))
        UndotreeToggle
        UndotreeFocus
    else
        UndotreeHide
    endif
endf

nnoremap <silent> <C-n> :bnext<CR>
nnoremap <silent> <C-p> :bprev<CR>

" vim-bufferline
let g:bufferline_show_bufnr = 0

" colors and appearance
let g:gruvbox_material_better_performance = 1
let g:everforest_better_performance = 1
colorscheme everforest

" set a constant horizontal line between splits
let g:HorizLine1='─'
let g:HorizLine2=''
function FillStatus()
    return repeat(g:HorizLine1, winwidth('%'))
endf
set statusline=%{FillStatus()}
exec "set fillchars=stlnc:" . HorizLine1 . ",stl:" . HorizLine2

function TransparentBg()
    hi StatusLine guifg=#505050 ctermfg=darkgrey ctermbg=NONE guibg=NONE
    hi StatusLineNC guifg=#505050 ctermfg=darkgrey ctermbg=NONE guibg=NONE
    hi VertSplit guifg=#505050 ctermfg=darkgrey ctermbg=NONE guibg=NONE
    hi EndOfBuffer guifg=#404040 ctermfg=darkgrey guibg=NONE ctermbg=NONE
    hi Normal guibg=NONE ctermbg=NONE
    hi LineNr guibg=NONE ctermbg=NONE
    hi CursorLineNr guibg=NONE ctermbg=NONE
    hi SignColumn guibg=NONE ctermbg=NONE
endf
autocmd ColorScheme * call TransparentBg()
call TransparentBg()

" load other configs
source ~/.config/nvim/term.vim
