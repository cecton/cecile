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

syntax on
set listchars=nbsp: ,tab:\ \ ,eol:↵
set tabstop=4 softtabstop=4 shiftwidth=4
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
