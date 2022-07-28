" install vim-plug if not installed
let s:VimPlugPath = stdpath('data') . '/site/autoload/plug.vim'
let s:VimPlugURL = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
if empty(glob(s:VimPlugPath))
    echo 'Installing vim-plug...'
    call system('curl --create-dirs -fsLo '.s:VimPlugPath.' '.s:VimPlugURL)
    autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

" set the leader key to space
let mapleader = " "

" set the comment style of unknown files to sharp
set commentstring=#\ %s

" enable truecolor
set termguicolors

" plugins
call plug#begin('~/.local/share/nvim/plugged')
Plug 'sainnhe/gruvbox-material'
Plug 'maxboisvert/vim-simple-complete'
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-eunuch'
Plug 'chaoren/vim-wordmotion'
Plug 'easymotion/vim-easymotion'
Plug 'mbbill/undotree'
Plug 'drmikehenry/vim-headerguard'
Plug 'voldikss/vim-floaterm'
Plug 'akinsho/bufferline.nvim', {'tag': 'v2.*'}
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/nvim-treesitter-refactor'
call plug#end()

" basics
set ignorecase
set smartcase
set hidden
set updatetime=2000
set visualbell
set number
set relativenumber
set colorcolumn=80
set nowrap
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set smartindent
set list lcs=tab:\-\ "
set scrolloff=5
set sidescrolloff=10
set matchpairs+=<:>
set nrformats+=unsigned
set laststatus=0
set mouse=a
set cursorline
set title titlestring=nvim\ -\ %t
set wildmenu
set wildignorecase
set wildmode=longest:full,full
set path+=**
set shortmess+=ac
let g:netrw_dirhistmax = 0
set noswapfile
set undofile
"set notimeout

" allow the lf file manager to open in vim terminals
" without it being considered as a nested instance
unlet $LF_LEVEL

" use c syntax for *.h files
let g:c_syntax_for_h = 1

" use actual tab characters for some filetypes
autocmd Filetype c,cpp,lua setlocal noexpandtab

" show cursorline only on the active window
autocmd WinEnter * set cursorline
autocmd WinLeave * set nocursorline

" on save, delete all trailing whitespace at the end of the lines,
" and trailing newlines at the end of the file.
function s:NoTrailing()
    " if the file is a binary, don't do anything
    if !!search('\%u0000', 'wn') | return | endif
    let line = line(".")
    let col = col(".")
    %s/\s\+$//e
    %s/\n\+\%$//e
    call cursor(line, col)
endf
autocmd BufWritePre * call <SID>NoTrailing()

nnoremap <C-f> :e **/*

" buffer navigation
nnoremap <silent><C-n>   :BufferLineCycleNext<CR>
nnoremap <silent><C-p>   :BufferLineCyclePrev<CR>
nnoremap <silent><C-S-n> :BufferLineMoveNext<CR>
nnoremap <silent><C-S-p> :BufferLineMovePrev<CR>
nnoremap <silent>gb      :BufferLinePick<CR>
" jump to different buffers using <Leader>1 through <Leader>9
for n in range(1, 9)
    exec "nnoremap <silent><Leader>" . n .
      \ " :BufferLineGoToBuffer " . n . "<CR>"
endfor


" center the cursor horizontally
nnoremap <silent> z. zs20zh

" indent
vmap <C-h> <gv4h
vmap <C-l> >gv4l

" quick macro
nnoremap Q @q

" paste the last yanked text
noremap <Leader>p "0p
noremap <Leader>P "0P

" copy/paste from clipboard
vnoremap <C-c> "+y
map <C-v> "+P

" clear search
nnoremap <silent><Leader>cs :nohlsearch<CR>

" compile markdown to pdf (requires pandoc and wkhtmltopdf-static)
nnoremap <Leader>cc :!pandoc -s --pdf-engine=wkhtmltopdf -o %:r:S.pdf %:S<CR>
nnoremap <Leader>vv :silent !setsid -f zathura %:r:S.pdf<CR>

" diff
nmap <Leader>gh :diffget //2<CR>
nmap <Leader>gl :diffget //3<CR>
nmap <Leader>gg :diffget<CR>
nmap <Leader>gp :diffput<CR>

" fuzzy searching
nnoremap <Leader>ff :Files<CR>
nnoremap <leader>fl :Lines<CR>
nnoremap <leader>rg :Rg<CR>

" splits and windows
nnoremap <silent><Leader>vs :vs<CR>
nnoremap <silent><Leader>sp :sp<CR>
nmap <silent><C-h> :wincmd h<CR>
nmap <silent><C-j> :wincmd j<CR>
nmap <silent><C-k> :wincmd k<CR>
nmap <silent><C-l> :wincmd l<CR>
nnoremap <silent><Leader>i :vertical resize +10<CR>
nnoremap <silent><Leader>d :vertical resize -10<CR>
nnoremap <silent><Leader>I :resize +10<CR>
nnoremap <silent><Leader>D :resize -10<CR>

" search for the visually selected text
vnoremap <silent> // :<C-U>
  \ let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \ gvy/<C-R>=&ic?'\c':'\C'<CR><C-R><C-R>=substitute(
  \ escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \ gVzv:call setreg('"', old_reg, old_regtype)<CR>

" perform replace on visually-selected text
vnoremap <C-r> "hy:%s`\(<C-r><C-r>=escape(@h, '\.*$`~[')<CR>
  \\)``gc<left><left><left>

" text objects for c-style functions ('daf', 'cif', ...)
xnoremap <silent> if :<C-u>call search("^}") \| normal! V%{j<CR>
onoremap <silent> if :<C-u>call search("^}") \| normal! V%{j<CR>
xnoremap <silent> af :<C-u>call search("^}") \| normal! jVk%{j<CR>
onoremap <silent> af :<C-u>call search("^}") \| normal! jVk%{j<CR>

" insert a function skeleton
nnoremap <Leader>fn i()<CR>{<CR>}<UP><UP><LEFT>
inoremap <C-f> ()<CR>{<CR>}<UP><UP><LEFT>

" equalize window sizes upon vim resize
autocmd VimResized * wincmd =

" set the compiler to shellcheck on shell scripts
autocmd FileType sh,bash compiler shellcheck

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

" detect filetypes through the SUDO_COMMAND environment variable.
" this functionality was in the vim-eunuch plugin, but it was removed from
" it in commit cceba47 due to it not being set by the sudoedit program anymore.
" but if you manually set it in the shell, this functionality is still useful:
" sudoedit() { SUDO_COMMAND="sudoedit $*" command sudoedit "$@" ;}
" source code: https://github.com/tpope/vim-eunuch/blob/6c8387a/plugin/eunuch.vim#L282-L295
function s:SudoEditInit() abort
    let files = split($SUDO_COMMAND, ' ')[1:-1]
    if len(files) ==# argc()
        for i in range(argc())
            execute 'autocmd BufEnter' fnameescape(argv(i))
              \ 'if empty(&filetype) || &filetype ==# "conf"'
              \ '|doautocmd filetypedetect BufReadPost' fnameescape(files[i])
              \ '|endif'
        endfor
    endif
endf
if $SUDO_COMMAND =~# '^sudoedit '
    call s:SudoEditInit()
endif

" vim-simple-complete
"let g:vsc_type_complete = 0
"set completeopt=menu,longest

" easymotion
let g:EasyMotion_smartcase = 1
nmap s <Plug>(easymotion-s2)
nmap S <Plug>(easymotion-s2)
vmap s <Plug>(easymotion-s2)
vmap S <Plug>(easymotion-s2)

" floaterm
let g:floaterm_keymap_toggle = '<C-b>'
let g:floaterm_keymap_new    = '<F12>'
let g:floaterm_keymap_next   = '<F11>'
let g:floaterm_keymap_kill   = '<F10>'
let g:floaterm_width = 0.9
let g:floaterm_height = 0.9
let g:floaterm_autoclose = 2
autocmd VimResized * FloatermUpdate

" colors and appearance
let g:gruvbox_material_better_performance = 1
let g:gruvbox_material_background = 'hard'
let g:everforest_better_performance = 1
let g:everforest_background = 'hard'
colorscheme gruvbox-material

" set a constant horizontal line between splits
let g:HorizLine1='─'
let g:HorizLine2=''
function FillStatus()
    return repeat(g:HorizLine1, winwidth('%'))
endf
set statusline=%{FillStatus()}
exec "set fillchars=stlnc:" . HorizLine1 . ",stl:" . HorizLine2

function s:ChangeColors()
    hi VertSplit     guifg=#505050 ctermfg=darkgrey ctermbg=NONE guibg=NONE
    hi StatusLine    guifg=#505050 ctermfg=darkgrey ctermbg=NONE guibg=NONE
    hi StatusLineNC  guifg=#505050 ctermfg=darkgrey ctermbg=NONE guibg=NONE
endf
autocmd ColorScheme * call s:ChangeColors()
call s:ChangeColors()

" persian langmap
set langmap=۱1,۲2,۳3,۴4,۵5,۶6,۷7,۸8,۹9,۰0,٬@,٫#,﷼$,٪%,×^,،&,ـ_
set langmap+=ضq,صw,ثe,قr,فt,غy,عu,هi,خo,حp,ج[,چ]
set langmap+=شa,سs,یd,بf,لg,اh,تj,نk,مl,ک\\;,گ'
set langmap+=ظz,طx,زc,رv,ذb,دn,پm,و\\,
set langmap+=ْQ,ٌW,ٍE,ًR,ُT,ِY,َU,ّI,
set langmap+=ؤA,ئS,يD,إF,أG,آH,ةJ,»K,«L
set langmap+=كZ,ژC,ٰV,‌B,ٔN,ءM,؟?

" ===============
" = Lua Section
" ===============

lua << EOF

require("nvim-treesitter.configs").setup{
    ensure_installed = { "c", "cpp", "python", "lua", "bash", "vim" },
    highlight = { enable = true },
    refactor = {
        highlight_current_scope = { enable = false },
        smart_rename = {
            enable = true,
            keymaps = { smart_rename = "grr" },
        },
        navigation = {
            enable = true,
            keymaps = {
                goto_definition = "gnd",
                list_definitions = "gnD",
                list_definitions_toc = "gO",
                goto_next_usage = "<a-*>",
                goto_previous_usage = "<a-#>",
            },
        },
    },
}

require("bufferline").setup{
    options = {
        -- separator_style = "slant",
        sort_by = "insert_after_current",
        show_close_icon = false,
        show_buffer_close_icons = false,
        right_mouse_command = nil,
        middle_mouse_command = nil,
    }
}

EOF
