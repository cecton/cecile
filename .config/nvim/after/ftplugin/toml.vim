" always use spaces instead of tabs
setlocal expandtab tabstop=4 softtabstop=4 shiftwidth=4 smartindent number rnu

" Show invalid and wrong characters
highlight Invalid ctermbg=red guibg=red
match Invalid /\t\|\s\+$\|[^\x00-\xff]\+/
