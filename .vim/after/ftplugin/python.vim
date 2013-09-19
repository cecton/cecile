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

inoremap <tab> <c-r>=InsertTabWrapper("forward")<cr>
inoremap <s-tab> <c-r>=InsertTabWrapper("backward")<cr>
