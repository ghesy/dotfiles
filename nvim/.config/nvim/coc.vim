" disabled by default
let g:coc_start_at_startup = v:false

" coc maps
nmap <Leader>cd :CocDiagnostics<CR>
nmap <Leader>gd <Plug>(coc-definition)
nmap <Leader>gr <Plug>(coc-references)
nmap <Leader>gy <Plug>(coc-type-definition)
nmap <Leader>gi <Plug>(coc-implementation)
nmap <leader>rn <Plug>(coc-rename)
nmap <Leader>qf <Plug>(coc-fix-current)
imap <C-s> <Plug>(coc-snippets-expand)
nnoremap <silent>K :call CocActionAsync('doHover')<cr>

" tab navigates autocomplete menu
function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
endf

inoremap <silent><expr> <Tab>
   \ pumvisible() ? "\<C-n>" :
   \ <SID>check_back_space() ? "\<Tab>" :
   \ coc#refresh()

" install coc extensions
let g:coc_global_extensions = [
      \'coc-markdownlint',
      \'coc-marketplace',
      \'coc-gitignore',
      \'coc-python',
      \'coc-clangd',
      \'coc-json',
      \'coc-go'
      \]
