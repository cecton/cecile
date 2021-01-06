" show special characters
setlocal list listchars=nbsp: ,tab:\ \ 

" always use tabs
setlocal expandtab tabstop=4 softtabstop=4 shiftwidth=4 smartindent

" show invalid and wrong characters
highlight Invalid ctermbg=red guibg=red
match Invalid /\t\|\s\+$/

" Highlight lines to big & wrap automatically
setlocal cc=80 tw=79
highlight ColorColumn ctermbg=8

" try to keep the file clean
au BufWrite <buffer> %s/\s\+$//e
