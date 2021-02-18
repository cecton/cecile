" always use spaces instead of tabs
setlocal expandtab tabstop=2 softtabstop=2 shiftwidth=2 smartindent number rnu

" Show invalid and wrong characters
highlight Invalid ctermbg=red guibg=red
match Invalid /\t\|\s\+$\|[^\x00-\xff]\+/
