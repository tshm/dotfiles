" Plugin setup. {{{
if &compatible
  set nocompatible
endif
set runtimepath+=~/.cache/dein/repos/github.com/Shougo/dein.vim

call dein#begin('~/.cache/dein')
call dein#add('~/.cache/dein/repos/github.com/Shougo/dein.vim')

call dein#add('neoclide/coc.nvim')
call dein#add('itchyny/lightline.vim')
call dein#add('Shougo/denite.nvim')
call dein#add('rafi/vim-denite-session')
call dein#add('SirVer/ultisnips')
call dein#add('honza/vim-snippets')
call dein#add('tpope/vim-commentary')
call dein#add('machakann/vim-sandwich')
call dein#add('dense-analysis/ale')
call dein#add('tpope/vim-sleuth')
call dein#add('tpope/vim-fugitive')
call dein#add('sheerun/vim-polyglot')
call dein#end()

filetype plugin indent on
syntax enable

if dein#check_install()
  call dein#install()
endif
" }}}

" COC setup. {{{
" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
  \ pumvisible() ? "\<C-n>" :
  \ <SID>check_back_space() ? "\<TAB>" :
  \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
" Or use `complete_info` if your vim support it, like:
" inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap for do codeAction of current line
nmap <leader>ac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Create mappings for function text object, requires document symbols feature of languageserver.
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

" Use <TAB> for select selections ranges, needs server support, like: coc-tsserver, coc-python
nmap <silent> <TAB> <Plug>(coc-range-select)
xmap <silent> <TAB> <Plug>(coc-range-select)

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" use `:OR` for organize import of current buffer
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add status line support, for integration with other plugin, checkout `:h coc-status`
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Using CocList
" Show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>
" }}}

" VimShell {{{
let g:vimshell_user_prompt = 'fnamemodify(getcwd(), ":~")'
let g:vimshell_right_prompt = 'vimshell#vcs#info("(%s)-[%b]", "(%s)-[%b|%a]")'
let g:vimshell_enable_smart_case = 1
"nmap <F2> <Plug>(vimshell_switch)
" }}}

" Denite {{{
call denite#custom#var('session', 'path', '~/.vim-sessions')
call denite#custom#option('_', 'statusline', v:false)
call denite#custom#option('_', 'split', 'floating')
call denite#custom#option('_', 'start_filter', v:true)
call denite#custom#var('file', 'command',
\ ['rg', '--files', '--glob', '!.git'])
call denite#custom#var('file/rec', 'command',
\ ['rg', '--files', '--glob', '!.git'])
" Ripgrep command on grep source {{{
call denite#custom#var('grep', 'command', ['rg'])
call denite#custom#var('grep', 'default_opts',
    \ ['-i', '--vimgrep', '--no-heading'])
call denite#custom#var('grep', 'recursive_opts', [])
call denite#custom#var('grep', 'pattern_opt', ['--regexp'])
call denite#custom#var('grep', 'separator', ['--'])
call denite#custom#var('grep', 'final_opts', [])
" }}}
nnoremap <silent> <Leader>f  :<C-u>Denite file<CR>
nnoremap <silent> <Leader>h  :<C-u>Denite file/old<CR>
nnoremap <silent> <Leader>b  :<C-u>Denite buffer<CR>
nnoremap <silent> <Leader>R  :<C-u>Denite file/rec<CR>
nnoremap <silent> <Leader>r  :<C-u>DeniteBufferDir file<CR>
nnoremap <silent> <Leader>y  :<C-u>Denite history/yank<CR>
nnoremap <silent> <Leader>c  :<C-u>Denite change<CR>
nnoremap <silent> <Leader>j  :<C-u>Denite jump<CR>
nnoremap <silent> <Leader>/  :<C-u>Denite line<CR>
nnoremap <silent> <Leader>*  :<C-u>DeniteCursorWord line<CR>
nnoremap <silent> <Leader>g  :<C-u>DeniteCursorWord grep:.<CR>
nnoremap <silent> <Leader>s  :<C-u>Denite session<CR>
nnoremap <silent> <Leader>S  :<C-u>Denite source<CR>
nnoremap <silent> <Leader>m  :<C-u>Denite menu:main<CR>
vnoremap <silent> <Leader>m  "zy:<C-u>Denite menu:vmain<CR>
autocmd FileType denite call s:denite_keys()
function! s:denite_keys() abort
  nnoremap <silent><buffer><expr> <CR>    denite#do_map('do_action')
  nnoremap <silent><buffer><expr> d       denite#do_map('do_action', 'delete')
  nnoremap <silent><buffer><expr> p       denite#do_map('do_action', 'preview')
  nnoremap <silent><buffer><expr> <Tab>   denite#do_map('choose_action')
  nnoremap <silent><buffer><expr> <Esc>   denite#do_map('quit')
  nnoremap <silent><buffer><expr> q       denite#do_map('quit')
  nnoremap <silent><buffer><expr> i       denite#do_map('open_filter_buffer')
  nnoremap <silent><buffer><expr> <Space> denite#do_map('toggle_select').'j'
endfunction
autocmd FileType denite-filter call s:denite_filter_my_settings()
function! s:denite_filter_my_settings() abort
  imap <silent><buffer> jj <Plug>(denite_filter_quit)
  inoremap <silent><buffer><expr> <CR> denite#do_map('do_action')
  imap <silent><buffer><expr> <Esc> denite#do_map('quit')
endfunction
call denite#custom#option('default', 'prompt', '>>')
"{{{ menu definition
let s:menus = {}
let s:menus.main = {'description' : 'shortcuts'}
let s:menus.main.command_candidates = [
  \['git status'                , 'Gstatus'],
  \['git diff'                  , 'Gvdiff'],
  \['git commit'                , 'Gcommit'],
  \['git log current-file'      , 'Glog | copen'],
  \['git blame'                 , 'Gblame'],
  \['git ls-files'              , 'Denite file_rec/git'],
  \['git grep'                  , 'Denite grep/git'],
  \['paste from clipboard'      , 'normal "+gP'],
  \['vdiffsplit'                , 'vert diffs #'],
  \['toggle wrap'               , 'set wrap!'],
  \['toggle list'               , 'set list!'],
  \]
let s:menus.vmain = {'description' : 'shortcuts for visual'}
let s:menus.vmain.command_candidates = [
  \['git log current-block'     , "'<,'>Glog | copen"],
  \['comment block'             , "'<,'>TCommentBlock"],
  \['copy to clipboard'         , "call setreg('+',@z)"],
  \] " }}}
call denite#custom#var('menu', 'menus', s:menus)
" }}}

" ale {{{
nmap <silent> <C-p> <Plug>(ale_previous_wrap)
nmap <silent> <C-n> <Plug>(ale_next_wrap)
let g:ale_lint_on_save = 1
let g:ale_fix_on_save = 1
let g:ale_lint_on_text_changed = 0
let g:ale_open_list = 0
let g:indent_guides_enable_on_vim_startup = 1
let g:ale_set_loclist = 0
let g:ale_set_quickfix = 1

" let g:ale_fixers = {'javascript': ['standard']}
" let g:ale_linters = {'javascript': ['']}
" }}}

" GtagsCScope {{{
set cscopetag
let GtagsCscope_Auto_Load=0
" }}}

" Elm {{{
let g:elm_setup_keybindings = 0
let g:elm_make_output_file = '/tmp/tmp.js'
let g:elm_format_autosave = 1
" }}}

" vim: foldmethod=marker
