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

"Plug 'neoclide/coc.nvim', {'branch':'release'}
"Plug 'jackguo380/vim-lsp-cxx-highlight'
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
set list lcs=tab:\\ "
set background=dark
set nocursorline
set signcolumn=no
set scrolloff=5
set sidescrolloff=5
set backspace=indent,eol,start
set matchpairs+=<:> " use % to jump between pairs

" searching
set ignorecase
set smartcase
set incsearch
set hlsearch

" files
set undofile
set noswapfile
set nobackup
set pyxversion=3

" cmd
set cmdheight=1
set laststatus=0
set showcmd
set noshowmode

" other
let g:netrw_dirhistmax = 0
set shortmess+=c

" aliases
command W    execute "w"
command Wq   execute "wq"
command Q    execute "q"
command Qa   execute "qa"
command Wqa  execute "wqa"

" search for files natively in vim
set path+=**
set wildignore+=**/.git/**
set wildignore+=**/node_modules/**

" on save, deletes all trailing whitespace and newlines at end of file.
autocmd BufWritePre * %s/\s\+$//e
autocmd BufWritePre * %s/\n\+\%$//e

" open terminal in vim's pwd
nnoremap <silent>U :silent !termopen $PWD<CR>

" center the cursor horizontally
nnoremap <silent> z. :<C-u>normal! zszH<CR>

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
nnoremap <Leader>rb :BLines<CR>
nnoremap <leader>rg :Rg<CR>
map <leader>fb :Buffers<CR>

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
nnoremap <silent><Leader>ON :call Onlybuff()<CR>
nnoremap <silent><Leader>bw :call Killbuff()<CR>
nnoremap <silent><Leader>bd :call Killbuff()<CR>

" search for visually selected text.
vnoremap <silent> // :<C-U>
  \ let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \ gvy/<C-R>=&ic?'\c':'\C'<CR><C-R><C-R>=substitute(
  \ escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \ gVzv:call setreg('"', old_reg, old_regtype)<CR>

" perform replace on visually-selected text
vnoremap <C-r> "hy:%s/<C-r>h//gc<left><left><left>

" move between buffers
function BufferNavigationMaps()
    nnoremap <silent> <C-n>   :bnext<CR>
    nnoremap <silent> <C-p>   :bprev<CR>
endfunction
call BufferNavigationMaps()

" undotree
nnoremap <silent><Leader>ut :call UndoTreeRun()<CR>
autocmd BufEnter * call FixBufferNavigationMaps()

function UndoTreeRun()
    if buflisted(buffer_number('%'))
        UndotreeToggle
        UndotreeFocus
    else
        UndotreeHide
    endif
    call FixBufferNavigationMaps()
endfunction

function FixBufferNavigationMaps()
    if ( bufname('%') =~# "undotree_" || bufname('%') =~# "diffpanel_" )
        silent! nunmap <C-n>
        silent! nunmap <C-p>
    else
        call BufferNavigationMaps()
    endif
endfunction

" reload file if changed
autocmd CursorHold,CursorHoldI * silent checktime
autocmd FocusGained * silent checktime

" colors
colorscheme off
set statusline=─
set fillchars=stl:-,stlnc:─
function FixColors()
    hi StatusLine guifg=#404040 ctermfg=darkgrey ctermbg=NONE guibg=NONE
    hi StatusLineNC guifg=#404040 ctermfg=darkgrey ctermbg=NONE guibg=NONE
    hi VertSplit guifg=#404040 ctermfg=darkgrey ctermbg=NONE guibg=NONE
    hi Normal guibg=NONE ctermbg=NONE
    hi LineNr guibg=NONE ctermbg=NONE
    hi SignColumn guibg=NONE ctermbg=NONE
endfunction
autocmd ColorScheme * call FixColors()
call FixColors()

" recognise double-slash cpp-style comments in json files
autocmd FileType json syntax match Comment +\/\/.\+$+

" load other configs
source ~/.config/nvim/killbuff.vim
source ~/.config/nvim/term.vim
