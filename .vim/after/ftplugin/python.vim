" Magical <tab> feature
fu! InsertTabWrapper(direction)
  let char_before = col('.') - 1
  if !char_before || getline('.')[char_before - 1] !~ '\k'
    return "\<tab>"
  elseif "backward" == a:direction
    return "\<c-p>"
    "return "\<c-x>\<c-o>"
  else
    return "\<c-n>"
    "return "\<c-x>\<c-o>"
  endif
endfu
"inoremap <tab> <c-r>=InsertTabWrapper("forward")<cr>
"inoremap <s-tab> <c-r>=InsertTabWrapper("backward")<cr>

" colorize
syntax on

" For Python files, always use spaces instead of tabs
setlocal expandtab tabstop=4 softtabstop=4 shiftwidth=4

" Show invalid and wrong characters
highlight Invalid ctermbg=red guibg=red
match Invalid /\t\|\s\+$\|[^\x00-\xff]\+/

" Highlight lines to big
highlight OverLength term=underline ctermbg=8
2match OverLength /\%80v.\+/

" Check file integrity on save -- too slow
"autocmd FileType python compiler pylint
