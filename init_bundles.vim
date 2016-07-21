" VimPlug setup. {{{
fun SetupVimPlug()
  let autoload_dir = expand('$HOME') . '/.vim/autoload/'
  let vimplugurl = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  if !filereadable(autoload_dir.'plug.vim')
    execute '!curl -fLo '.autoload_dir.'plug.vim --create-dirs '.vimplugurl
    autocmd VimEnter * PlugInstall | source $MYVIMRC
  endif
endfun
call SetupVimPlug()

call plug#begin('~/.vim/plugged')
Plug 'Shougo/unite.vim'
Plug 'tshm/unite-gitlsfiles'
Plug 'Shougo/neomru.vim'
Plug 'Shougo/unite-session'
Plug 'Shougo/neocomplete'
Plug 'tomtom/tcomment_vim'
Plug 'tpope/vim-surround'
Plug 'scrooloose/syntastic'
Plug 'tpope/vim-fugitive'
Plug 'sukima/xmledit', {'for': 'xml'}
Plug 'pangloss/vim-javascript', {'for': 'javascript'}
Plug 'ElmCast/elm-vim', {'for': 'elm'}
Plug 'leafgarland/typescript-vim'
"let g:syntastic_typescript_tsc_args = "--experimentalDecorators --target ES5"
"Plug 'eagletmt/ghcmod-vim', {'for': 'haskell'}
"Plug 'Konfekt/FastFold'
"Plug 'Shougo/vimproc.vim'
call plug#end()
" }}}

" VimShell {{{
let g:vimshell_user_prompt = 'fnamemodify(getcwd(), ":~")'
let g:vimshell_right_prompt = 'vimshell#vcs#info("(%s)-[%b]", "(%s)-[%b|%a]")'
let g:vimshell_enable_smart_case = 1
"nmap <F2> <Plug>(vimshell_switch)
" }}}

" neocomplete setting {{{
let g:neocomplete#enable_at_startup = 1
" Use smartcase.
let g:neocomplete#enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 3
let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

" Define dictionary.
let g:neocomplete#sources#dictionary#dictionaries = {
  \ 'default' : ''
  \ }

" Define keyword.
if !exists('g:neocomplete#keyword_patterns')
  let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns['default'] = '\h\w*'

" Plugin key-mappings.
inoremap <expr><C-g> neocomplete#undo_completion()
inoremap <expr><C-l> neocomplete#complete_common_string()

" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  return (pumvisible() ? "\<C-y>" : "" ) . "\<CR>"
  " For no inserting <CR> key.
  "return pumvisible() ? "\<C-y>" : "\<CR>"
endfunction
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
" Close popup by <Space>.
"inoremap <expr><Space> pumvisible() ? "\<C-y>" : "\<Space>"

" AutoComplPop like behavior.
"let g:neocomplete#enable_auto_select = 1

" Shell like behavior(not recommended).
"set completeopt+=longest
"let g:neocomplete#enable_auto_select = 1
"let g:neocomplete#disable_auto_complete = 1
"inoremap <expr><TAB>  pumvisible() ? "\<Down>" : "\<C-x>\<C-u>"

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" Enable heavy omni completion.
if !exists('g:neocomplete#sources#omni#input_patterns')
  let g:neocomplete#sources#omni#input_patterns = {}
endif
"let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
"let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
"let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

" For perlomni.vim setting.
" https://github.com/c9s/perlomni.vim
let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'
" }}}

" Unite setting {{{
"nnoremap <silent> <Leader>f  :<C-u>UniteWithCurrentDir -buffer-name=files file <CR>
nnoremap <silent> <Leader>f  :<C-u>Unite -buffer-name=files file file/new<CR>
nnoremap <silent> <Leader>h  :<C-u>Unite -buffer-name=files file_mru bookmark<CR>
nnoremap <silent> <Leader>b  :<C-u>Unite -buffer-name=files buffer<CR>
nnoremap <silent> <Leader>B  :<C-u>Unite -buffer-name=files bookmark<CR>
nnoremap <silent> <Leader>F  :<C-u>Unite -buffer-name=file_rec file_rec<CR>
nnoremap <silent> <Leader>R  :<C-u>UniteWithBufferDir -buffer-name=file_rec file_rec<CR>
nnoremap <silent> <Leader>r  :<C-u>UniteWithBufferDir -buffer-name=files file file/new<CR>
nnoremap <silent> <Leader>y  :<C-u>Unite history/yank<CR>
nnoremap <silent> <Leader>c  :<C-u>Unite change<CR>
nnoremap <silent> <Leader>j  :<C-u>Unite jump<CR>
nnoremap <silent> <Leader>/  :<C-u>Unite line<CR>
nnoremap <silent> <Leader>*  :<C-u>UniteWithCursorWord line<CR>
nnoremap <silent> <Leader>?  :<C-u>Unite vimgrep<CR>
nnoremap <silent> <Leader>s  :<C-u>call Unite_save_prevsession()<CR>
nnoremap <silent> <Leader>S  :<C-u>Unite source<CR>
nnoremap <silent> <Leader>v  :<C-u>Unite gitlsfiles<CR>
" makes it easier to go back to the last session.
" this special session name is "0prev"
function! Unite_save_prevsession() "{{{
  let g:Prev_session = v:this_session
  exec "mksession! " . v:this_session
  UniteSessionSave .0prev
  Unite session
endfunction "}}}
"let g:unite_source_session_enable_auto_save = 1
autocmd SessionLoadPost * call s:unite_bkup_session()
function! s:unite_bkup_session() "{{{
  if -1 != match(v:this_session, '0prev')
    let v:this_session = g:Prev_session
  endif
  let l:path = g:unite_data_directory . "/session/"
  call rename(l:path . ".0prev.vim", l:path . "0prev.vim")
endfunction "}}}
"nnoremap <silent> <Leader>s
"        \ :<C-u>Unite -buffer-name=files -no-split
"        \ jump_point file_point buffer_tab
"        \ file_rec:! file file/new file_mru<CR>
let g:unite_enable_start_insert = 1
let g:unite_source_history_yank_enable = 1
let g:unite_source_file_mru_limit = 100
let g:unite_source_file_mru_filename_format = ''
autocmd FileType unite call s:unite_my_settings()
function! s:unite_my_settings() "{{{
  nmap     <buffer> <ESC> <Plug>(unite_exit)
  imap     <buffer> jj    <Plug>(unite_insert_leave)
  inoremap <buffer> <C-l> <C-x><C-u><C-p><Down>
endfunction"}}}
" }}}

" TagBar {{{
nnoremap <silent> <F8> :TagbarToggle<CR>
" }}}

" GtagsCScope {{{
set cscopetag
let GtagsCscope_Auto_Load=0
" }}}

" Syntastic {{{
let g:syntastic_enable_signs=1
let g:syntastic_always_populate_loc_list=1
let g:syntastic_auto_loc_list=1
" }}}

" Elm {{{
let g:elm_setup_keybindings = 0
let g:elm_syntastic_show_warnings = 1
let g:elm_make_output_file = '.tmp.js'
" }}}

" vim: foldmethod=marker
