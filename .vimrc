if stridx($TERM, "st") > -1
"if strlen($DISPLAY) > 0 && stridx($TERM, "xterm") < 0
    set background=dark
    colorscheme solarized
endif

nmap <F1> <NOP>
nmap <F11> :set invhlsearch<CR>
nmap <F12> :wa<CR>
imap <F12> <Esc>:wa<CR>

syntax on
set spell
set listchars=nbsp: ,tab:\ \ ,eol:↵
set tabstop=4 softtabstop=4 shiftwidth=4
" disable automatic indent of comments and sometimes automatic comment
set formatoptions-=r

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
