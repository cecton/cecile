" show special characters
syntax on
setlocal list listchars=nbsp: ,tab:\ \ 

" always use tabs
set expandtab tabstop=4 softtabstop=4 shiftwidth=4

" show invalid and wrong characters
highlight Invalid ctermbg=red guibg=red
match Invalid /\t\|\s\+$/
