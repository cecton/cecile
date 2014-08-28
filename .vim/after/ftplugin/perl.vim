" Highlight lines to big
setlocal cc=80
highlight ColorColumn ctermbg=8

" Fix the stupid automatic indenting when typing comments
inoremap # X<C-H>#

" Show invalid and wrong characters
highlight Invalid ctermbg=red guibg=red
match Invalid /\s\+$/
