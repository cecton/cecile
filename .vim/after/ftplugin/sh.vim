setlocal expandtab tabstop=2 softtabstop=2 shiftwidth=2 smartindent rnu number

" Show invalid and wrong characters
highlight Invalid ctermbg=red guibg=red
match Invalid /\t\|\s\+$\|[^\x00-\xff]\+/

" Highlight lines to big
setlocal cc=80

au BufWrite <buffer> %s/\s\+$//e
