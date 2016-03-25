setlocal smartindent number rnu

" Show invalid and wrong characters
highlight Invalid ctermbg=red guibg=red
match Invalid /^ \+\|\s\+$\|[^\x00-\xff]\+/

" Highlight lines to big
setlocal cc=80

au BufWrite <buffer> %s/\s\+$//e
