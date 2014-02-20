" Highlight lines to big
setlocal cc=80
highlight ColorColumn ctermbg=8

" Show invalid and wrong characters
highlight Invalid ctermbg=red guibg=red
match Invalid /\s\+$/
