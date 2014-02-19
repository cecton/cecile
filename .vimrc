if stridx($TERM, "st") > -1
"if strlen($DISPLAY) > 0 && stridx($TERM, "xterm") < 0
    set background=dark
    colorscheme solarized
endif

nmap <F1> <NOP>
nmap <F11> :set invhlsearch<CR>
nmap <F12> :wa<CR>
imap <F12> <Esc>:wa<CR>

set listchars=nbsp: ,tab:\ \ ,eol:↵
set tabstop=4 softtabstop=4 shiftwidth=4

filetype plugin on
