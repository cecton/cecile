" For Python files, always use spaces instead of tabs
setlocal expandtab tabstop=4 softtabstop=4 shiftwidth=4 smartindent number rnu

" Fix the stupid automatic indenting when typing comments
inoremap # X<C-H>#

" Show invalid and wrong characters
highlight Invalid ctermbg=red guibg=red
match Invalid /\t\|\s\+$\|[^\x00-\xff]\+/

" Highlight lines to big
setlocal cc=80

" Check file integrity on save -- too slow
"autocmd FileType python compiler pylint

" try to keep the file clean when it's my repo
if matchstr(expand('%:p'), '^/home/cecile/repos/(python-(ya)?fastimport)') != ''
	au BufWrite <buffer> %s/\s\+$//e
endif
