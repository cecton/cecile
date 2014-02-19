" make XML more readable
syntax on
setlocal wrap linebreak

" always use spaces instead of tabs
setlocal expandtab tabstop=2 softtabstop=2 shiftwidth=2

" show invalid and wrong characters
highlight Invalid ctermbg=red guibg=red
match Invalid /\t\|\s\+$/
