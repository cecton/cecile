if $SHELL =~ 'bin/fish'
    set shell=/bin/sh
endif

syntax on

"if stridx($TERM, "rxvt") > -1
if strlen($DISPLAY) > 0 && stridx($TERM, "xterm") < 0
    set background=dark
    colorscheme solarized
endif

nmap <F1> <NOP>
nmap <F11> :set invhlsearch<CR>
nmap <F12> :wa<CR>
imap <F12> <Esc>:wa<CR>

set expandtab smartindent tabstop=4 softtabstop=4 shiftwidth=4

" highlight OverLength ctermbg=red ctermfg=white guibg=#592929
" match OverLength /\%81v.\+/

filetype plugin on

" autocmd FileType python compiler pylint " too slow for OpenERP

" set formatoptions-=r
