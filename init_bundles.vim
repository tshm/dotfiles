" VAM setup.
" {{{
fun SetupVAM()
  let vam_plugins = [
    \ "unite",
    \ "neocomplcache",
    \ "Syntastic",
    \ "vcscommand"
    \ ]
  let c = get(g:, 'vim_addon_manager', {})
  let g:vim_addon_manager = c
  let c.plugin_root_dir = expand('$HOME') . '/.vim/vim-addons'
  let &rtp.=(empty(&rtp)?'':',').c.plugin_root_dir.'/vim-addon-manager'
  " let g:vim_addon_manager = {}
  if !isdirectory(c.plugin_root_dir.'/vim-addon-manager/autoload')
    execute '!git clone --depth=1 git://github.com/MarcWeber/vim-addon-manager '
                \       shellescape(c.plugin_root_dir.'/vim-addon-manager', 1)
  endif
  call vam#ActivateAddons(vam_plugins, {'auto_install' : 0})
endfun
call SetupVAM()
" }}}

" VimShell
" {{{
let g:vimshell_user_prompt = 'fnamemodify(getcwd(), ":~")'
let g:vimshell_right_prompt = 'vimshell#vcs#info("(%s)-[%b]", "(%s)-[%b|%a]")'
let g:vimshell_enable_smart_case = 1
nmap <F2> <Plug>(vimshell_switch)
" }}}

" neocomplcache setting
" {{{
let g:acp_enableAtStartup = 0
" Use neocomplcache.
let g:neocomplcache_enable_at_startup = 1
" No autocomplete
let g:neocomplcache_disable_auto_complete = 1
" Use smartcase.
let g:neocomplcache_enable_smart_case = 1
" Define dictionary.
let g:neocomplcache_dictionary_filetype_lists = {
			\ 'default' : '',
			\ 'vimshell' : $HOME.'/.vimshell_hist'
			\ }
" Define keyword.
if !exists('g:neocomplcache_keyword_patterns')
	let g:neocomplcache_keyword_patterns = {}
endif
let g:neocomplcache_keyword_patterns['default'] = '\h\w*'
" Plugin key-mappings.
imap <C-u>  <Plug>(neocomplcache_start_unite_complete)
smap <C-k>  <Plug>(neocomplcache_snippets_expand)
inoremap <expr><C-g> neocomplcache#undo_completion()
inoremap <expr><C-l> neocomplcache#complete_common_string()
" <CR>: close popup and save indent.
inoremap <expr><CR>  neocomplcache#smart_close_popup() . "\<CR>"
" Manual completion
inoremap <expr><C-n> pumvisible() ? "\<C-n>" : "\<C-x>\<C-u>"
"inoremap <expr><C-n> pumvisible() ? "\<C-n>" : neocomplcache#manual_keyword_complete()
inoremap <expr><C-x><C-f>  neocomplcache#manual_filename_complete()
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
inoremap <expr><BS>  neocomplcache#smart_close_popup()."\<C-h>"
inoremap <expr><C-y> neocomplcache#close_popup()
inoremap <expr><C-e> neocomplcache#cancel_popup()
" Enable omni completion.
autocmd FileType css           setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript    setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python        setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml           setlocal omnifunc=xmlcomplete#CompleteTags
autocmd FileType cpp           setlocal omnifunc=omni#cpp#complete#Main
if !exists('g:neocomplcache_omni_patterns')
  let g:neocomplcache_omni_patterns = {}
endif
let g:neocomplcache_omni_patterns.c = '\%(\.\|->\)\h\w*'
let g:neocomplcache_omni_patterns.cpp = '\h\w*\%(\.\|->\)\h\w*\|\h\w*::'
" }}}

" Unite setting
" {{{
"nnoremap <silent> ,f  :<C-u>UniteWithCurrentDir -buffer-name=files file <CR>
nnoremap <silent> ,f  :<C-u>Unite -buffer-name=files file<CR>
nnoremap <silent> ,h  :<C-u>Unite -buffer-name=files file_mru bookmark<CR>
nnoremap <silent> ,b  :<C-u>Unite -buffer-name=files buffer_tab<CR>
nnoremap <silent> ,B  :<C-u>Unite -buffer-name=files bookmark<CR>
nnoremap <silent> ,R  :<C-u>Unite -buffer-name=file_rec file_rec<CR>
nnoremap <silent> ,r  :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
nnoremap <silent> ,R  :<C-u>Unite file_rec<CR>
nnoremap <silent> ,y  :<C-u>Unite history/yank<CR>
nnoremap <silent> ,g  :<C-u>Unite change<CR>
nnoremap <silent> ,j  :<C-u>Unite jump<CR>
nnoremap <silent> ,/  :<C-u>UniteWithCursorWord line<CR>
"nnoremap <silent> ,s  :<C-u>Unite session<CR>
nnoremap <silent> ,S  :<C-u>Unite source<CR>
nnoremap <silent> ,s
        \ :<C-u>Unite -buffer-name=files -no-split
        \ jump_point file_point buffer_tab
        \ file_rec:! file file/new file_mru<CR>
let g:unite_enable_start_insert = 1
let g:unite_source_history_yank_enable = 1
let g:unite_source_file_mru_limit = 100
let g:unite_source_file_mru_filename_format = ''
autocmd FileType unite call s:unite_my_settings()
function! s:unite_my_settings() "{{{
  nmap <buffer> <ESC>      <Plug>(unite_exit)
  imap <buffer> jj      <Plug>(unite_insert_leave)
  inoremap <buffer> <C-l>  <C-x><C-u><C-p><Down>
endfunction"}}}
" }}}

" TagBar
" {{{
nnoremap <silent> <F8> :TagbarToggle<CR>
" }}}

" GtagsCScope
" {{{
set cscopetag
let GtagsCscope_Auto_Load=0
" }}}

" Syntastic
" {{{
let g:syntastic_enable_signs=1
let g:syntastic_auto_loc_list=1
" }}}

" vim: foldmethod=marker
