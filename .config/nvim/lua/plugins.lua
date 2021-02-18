local execute = vim.api.nvim_command
local fn = vim.fn

local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

-- Auto install packer.nvim
if fn.empty(fn.glob(install_path)) > 0 then
  execute('!git clone https://github.com/wbthomason/packer.nvim '..install_path)
  execute('packadd packer.nvim')
  execute('PackerSync')
end

return require('packer').startup(function(use)
  -- Packer can manage itself as an optional plugin
  use 'wbthomason/packer.nvim'

  -- Visuals
  use 'gruvbox-community/gruvbox'

  -- Essentials
  use 'tpope/vim-commentary'
  use 'tpope/vim-surround'
  use 'editorconfig/editorconfig-vim'

  -- Fuzzy finding
  use 'junegunn/fzf'
  use 'junegunn/fzf.vim'

  -- LSP related
  use 'neovim/nvim-lspconfig'
  use 'nvim-lua/completion-nvim'
  use 'nvim-lua/lsp_extensions.nvim'
  use 'hrsh7th/vim-vsnip'
  use 'hrsh7th/vim-vsnip-integ'
  use 'ojroques/nvim-lspfuzzy'

  -- TreeSitter
  use 'nvim-treesitter/nvim-treesitter'
  use 'nvim-treesitter/completion-treesitter'

  -- Language specific
  use 'rust-lang/rust.vim'
end)
