require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = 'gnn',
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    }
  },
  refactor = {
    highlight_defintions = {
      enable = false
    },
    smart_rename = {
      -- enable = true,
      -- smart_rename = "grr",             -- mapping to rename reference under cursor
    },
    navigation = {
      -- enable = true,
      -- goto_definition = "gnd",          -- mapping to go to definition of symbol under cursor
      -- list_definitions = "gnD"          -- mapping to list all definitions in current file
    }
  },
  ensure_installed = 'rust'
}
