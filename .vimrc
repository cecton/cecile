set runtimepath+=~/.local/share/dein/repos/github.com/Shougo/dein.vim

set tabstop=4 softtabstop=4 shiftwidth=4 smartindent number rnu
syntax on

if dein#load_state('~/.local/share/dein')
	call dein#begin('~/.local/share/dein')

	call dein#add('~/.local/share/dein/repos/github.com/Shougo/dein.vim')

	call dein#add('prabirshrestha/asyncomplete.vim')
	call dein#add('prabirshrestha/async.vim')
	call dein#add('prabirshrestha/vim-lsp')
	call dein#add('prabirshrestha/asyncomplete-lsp.vim')
	call dein#add('editorconfig/editorconfig-vim')

	call dein#end()
	call dein#save_state()
endif

function! HighlightInvalid(config)
	" Show invalid and wrong characters
	if a:config['indent_style'] == 'tab'
		highlight Invalid ctermbg=red guibg=red
		match Invalid /  \+\|\s\+$\|[^\x00-\xff]\+/
	elseif a:config['indent_style'] == 'space'
		highlight Invalid ctermbg=red guibg=red
		match Invalid /\t\|\s\+$\|[^\x00-\xff]\+/
	endif

	return 0
endfunction

call editorconfig#AddNewHook(function('HighlightInvalid'))

if dein#check_install()
  call dein#install()
endif

if stridx($TERM, "256color") > -1
	set background=dark
	let g:solarized_termcolors=256
	colorscheme Tomorrow-Night-Eighties
	set spell
endif

" disable some annoying bindings
nmap Q <NOP>
nmap <F1> <NOP>
imap <F1> <NOP>

" shortcut to save all the buffers
nmap s :w<CR>
nmap <F12> :wa<CR>
imap <F12> <Esc>:wa<CR>

noremap <Leader>h :set invhlsearch<CR>
if $PLATFORM == "Darwin"
	" copy/past clipboard on OS X
	noremap <Leader>p :r !pbpaste<CR>
	noremap <Leader>P :-1r !pbpaste<CR>
	noremap <Leader>yy :+0w !pbcopy<CR>
	vnoremap <Leader>y :w !pbcopy<CR>
endif
if $PLATFORM == "Linux"
	" copy/past clipboard on Linux
	noremap <Leader>p :r !xsel -b -o<CR>
	noremap <Leader>P :-1r !xsel -b -o<CR>
	noremap <Leader>yy :+0w !xsel -b<CR>
	vnoremap <Leader>y :w !xsel -b<CR>
endif

" Avoid errors parsing listchar on some environments
set encoding=utf-8
set listchars=nbsp: ,tab:\ \ ,eol:↵
" disable automatic indent of comments and sometimes automatic comment
set formatoptions-=r
set nohlsearch
set ruler
inoremap # X<c-h>#

if stridx($TERM, "256color") > -1
	" underline spell mistakes
	hi clear SpellBad
	hi SpellBad cterm=underline
	hi clear SpellCap
	hi SpellCap cterm=underline
endif

" move the cursor in the virtual lines instead of real lines
noremap  <buffer> <silent> <Up>   gk
noremap  <buffer> <silent> <Down> gj
noremap  <buffer> <silent> <Home> g<Home>
noremap  <buffer> <silent> <End>  g<End>
inoremap <buffer> <silent> <Up>   <C-o>gk
inoremap <buffer> <silent> <Down> <C-o>gj
inoremap <buffer> <silent> <Home> <C-o>g<Home>
inoremap <buffer> <silent> <End>  <C-o>g<End>

filetype plugin on

if executable('rls')
	au User lsp_setup call lsp#register_server({
		\ 'name': 'rls',
		\ 'cmd': {server_info->['rustup', 'run', 'stable', 'rls']},
		\ 'workspace_config': {'rust': {'clippy_preference': 'on'}},
		\ 'whitelist': ['rust'],
		\ })
endif

" optional, always show the sign column to avoid jumping (not sure if it's useful)
" set signcolumn=yes

" allow <CR> to be inserted when the popup is visible
inoremap <expr> <CR> pumvisible() ? asyncomplete#close_popup() . "\<CR>" : "\<CR>"
