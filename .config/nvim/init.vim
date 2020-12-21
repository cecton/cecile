lua require'plugins'
lua require'lsp'
lua require'treesitter'

autocmd BufWritePost plugins.lua PackerCompile

set termguicolors
colorscheme gruvbox

set number
set relativenumber

" Always show the sign column, to avoid jumps on diagnostics
set signcolumn=yes

" Allow hidden buffers
set hidden

" Faster redrawing
set updatetime=250
set lazyredraw

" Live substitution preview
set incsearch
set inccommand=nosplit

" Use treesitter for folds
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set foldlevelstart=20

" Hightlight yanked text
augroup highlight_yank
  autocmd!
  autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank()
augroup END

" Autocompletion

" Show type hints for current line on cursor hold
autocmd CursorHold,CursorHoldI *.rs :lua require'lsp_extensions'.inlay_hints{ only_current_line = true }

set completeopt=menuone,noinsert,noselect
set shortmess+=c

let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 0.5 } }

let g:completion_enable_auto_popup = 0
let g:completion_enalbe_auto_paren = 1
let g:completion_enable_snippet = 'vim-vsnip'
let g:completion_customize_lsp_label = {
  \ 'Function': ' [function]',
  \ 'Method': ' [method]',
  \ 'Reference': ' [refrence]',
  \ 'Enum': ' [enum]',
  \ 'Field': 'ﰠ [field]',
  \ 'Keyword': ' [key]',
  \ 'Variable': ' [variable]',
  \ 'Folder': ' [folder]',
  \ 'Snippet': ' [snippet]',
  \ 'Operator': ' [operator]',
  \ 'Module': ' [module]',
  \ 'Text': 'ﮜ[text]',
  \ 'Class': ' [class]',
  \ 'Interface': ' [interface]'
  \}

imap <silent> <c-n>   <Plug>(completion_trigger)
imap <silent> <c-p>   <Plug>(completion_trigger)
imap          <Tab>   <Plug>(completion_smart_tab)
imap          <S-Tab> <Plug>(completion_smart_s_tab)

" Jump forward or backward
imap <expr> <Tab>   vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)' : '<Tab>'
smap <expr> <Tab>   vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)' : '<Tab>'
imap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<S-Tab>'
smap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<S-Tab>'

" LSP Bindings
nnoremap <silent> gD    <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> gd    <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gi    <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> gtd   <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
nnoremap <silent> gW    <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
nnoremap <leader>ca     <cmd>lua vim.lsp.buf.code_action()<CR>
nnoremap <leader>cf     <cmd>lua vim.lsp.buf.formatting()<CR>
nnoremap <leader>cr     <cmd>lua vim.lsp.buf.rename()<CR>
nnoremap <silent>d[     <cmd>lua vim.lsp.diagnostic.goto_prev()<CR>
nnoremap <silent>d]     <cmd>lua vim.lsp.diagnostic.goto_next()<CR>

" Fuzzy finder
map <leader><leader> :Files<cr>
map <space>,         :Buffers<cr>

" Navigation between windows
nnoremap <silent> <C-h> <C-w>h
nnoremap <silent> <C-j> <C-w>j
nnoremap <silent> <C-k> <C-w>k
nnoremap <silent> <C-l> <C-w>l

" Make C-a and C-e work in command mode
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
