" show special characters
setlocal list listchars=nbsp: ,tab:\ \ 

" always use tabs
setlocal expandtab tabstop=4 softtabstop=4 shiftwidth=4

" show invalid and wrong characters
highlight Invalid ctermbg=red guibg=red
match Invalid /\t\|\s\+$/

" Highlight lines to big
setlocal cc=80
highlight ColorColumn ctermbg=8
