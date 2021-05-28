" leader is space
let mapleader = " "

" install vim-plug
if ! filereadable(system('echo -n "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim"'))
    echo "installing vim-plug..."
    silent !mkdir -p ${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload
    silent !sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    autocmd VimEnter * PlugInstall
endif

" enable 24 bit color mode
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
set termguicolors

" plugins
call plug#begin('~/.local/share/nvim/plugged')

Plug 'neoclide/coc.nvim', {'branch':'release'}
Plug 'jackguo380/vim-lsp-cxx-highlight'
Plug 'drmikehenry/vim-headerguard', {'on':'HeaderguardAdd'}
Plug 'tpope/vim-fugitive', {'on':'Git'}
Plug 'tpope/vim-commentary'
Plug 'justinmk/vim-sneak'
Plug 'tpope/vim-surround'
Plug 'elzr/vim-json'
Plug 'kovetskiy/sxhkd-vim'
Plug 'tpope/vim-eunuch'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
Plug 'bling/vim-bufferline'
Plug 'pbrisbin/vim-colors-off'
Plug 'andreypopp/vim-colors-plain'
Plug 'jaredgorski/fogbell.vim'
Plug 'davidosomething/vim-colors-meh'
Plug 'sainnhe/gruvbox-material'
Plug 'junegunn/fzf', {'do': { -> fzf#install() }}
Plug 'junegunn/fzf.vim',
\ {'on':['Files','GFiles','Colors','Ag','Lines','Tags','BLines','Rg',
\  'Buffers','BTags','Marks','Windows','Locate','History','Snippets',
\  'Commits','BCommits','Commands','Maps','Helptags','Filetypes']}
Plug 'mbbill/undotree',
\ {'on':['UndotreeShow','UndotreeToggle','UndotreeFocus','UndotreeHide']}

call plug#end()

autocmd! User GoyoEnter Limelight
autocmd! User GoyoLeave Limelight!
let g:limelight_conceal_guifg = '#555555'

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
set laststatus=1
set showcmd
set noshowmode

" turn off netrw history
let g:netrw_dirhistmax = 0

" don't pass messages to |ins-completion-menu|.
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

" indentation
nmap <C-h> vip<
nmap <C-l> vip>
vmap <C-h> <gv4h
vmap <C-l> >gv4l

" quick macro
nnoremap Q @q

" paste the last yanked texts
noremap <Leader>p "0p
noremap <Leader>P "0P

" copy/paste
vnoremap <C-c> "+y
map <C-v> "+P

" clear search
nnoremap <silent><Leader>cs :let @/=''<CR>

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

" splits
nnoremap <silent><Leader>vs :vs<CR>
nnoremap <silent><Leader>sp :sp<CR>

" window commands
nmap <silent><C-h> :wincmd h<CR>
nmap <silent><C-j> :wincmd j<CR>
nmap <silent><C-k> :wincmd k<CR>
nmap <silent><C-l> :wincmd l<CR>
nnoremap <silent><Leader>i :vertical resize +5<CR>
nnoremap <silent><Leader>d :vertical resize -5<CR>
nnoremap <silent><Leader>I :resize +5<CR>
nnoremap <silent><Leader>D :resize -5<CR>
nnoremap <silent><Leader>eq :wincmd =<CR>

" jump to previously-accessed split
nnoremap <Leader><Leader> <C-W><C-p>

" close split/window
nnoremap <silent><Leader>wq :wincmd q<CR>

" only keep the current split/window
nnoremap <silent><Leader>on :only<CR>
nnoremap <silent><Leader>ON :call Onlybuff()<CR>

" close buffers
nnoremap <silent><Leader>bw :call Killbuff()<CR>
nnoremap <silent><Leader>bd :call Killbuff()<CR>

" search for visually selected text.
silent! nunmap //
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

" refresh open buffer if changed.
autocmd CursorHold,CursorHoldI * silent checktime
autocmd FocusGained * silent checktime

" recompile if configs updated
autocmd BufWritePost *.config/sxhkd/sxhkdrc !pkill --signal SIGUSR1 sxhkd
autocmd BufWritePost *tmux/tmux.conf !tmux source ~/.config/tmux/tmux.conf
autocmd BufWritePost *dunst/dunstrc !pkill dunst

" c/c++ highlighting settings
let g:lsp_cxx_hl_use_nvim_text_props = 0
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1

" colors
colorscheme off

function FixColors()
    " modify colors
    hi StatusLine guifg=#bbbbbb ctermfg=white cterm=NONE gui=NONE
    hi StatusLineNC guifg=#707070 ctermfg=darkgrey cterm=NONE gui=NONE

    " make vertical split line a sexy thin line
    set fillchars+=vert:│
    hi VertSplit guifg=#303030 ctermfg=darkgrey cterm=NONE gui=NONE ctermbg=NONE guibg=NONE

    " make background transparent
    hi Normal guibg=NONE ctermbg=NONE
    hi LineNr guibg=NONE ctermbg=NONE
    hi SignColumn guibg=NONE ctermbg=NONE
endfunction
autocmd ColorScheme * call FixColors()
call FixColors()

function On()
    CocStart
    colorscheme gruvbox-material
endfunction

function Off()
    CocDisable
    colorscheme off
endfunction

" " some settings for c/c++ code
" endfunction
" autocmd FileType * if (&ft=='c' || &ft=='cpp')
"  \ | colorscheme gruvbox-material | set cursorline | endif

" recognise double-slash cpp-style comments in json files
autocmd FileType json syntax match Comment +\/\/.\+$+

" load other configs
source ~/.config/nvim/status.vim
source ~/.config/nvim/killbuff.vim
source ~/.config/nvim/term.vim
source ~/.config/nvim/coc.vim
source ~/.config/nvim/gruvbox.vim

" no idea why I installed rooter
" rooter settings
"let g:rooter_patterns = ['.git', 'Makefile', '*.sln', 'build/env.sh', 'prjroot']
"let g:rooter_targets = '/,*.c,*.cpp,*.h,*.hh,*.cc,*.rs,*.css,*.js,*.ts,*.go,*.py,Makefile,*.gitignore,*.yml,*.yaml'
"let g:rooter_silent_chdir = 1
