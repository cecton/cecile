setlocal expandtab tabstop=4 softtabstop=4 shiftwidth=4 smartindent number rnu

" Show invalid and wrong characters
highlight Invalid ctermbg=red guibg=red
match Invalid /\s*\t \s*\|\s* \t\s*\|\s\+$\|[^\x00-\xff]\+/

" Highlight lines to big
setlocal cc=100
