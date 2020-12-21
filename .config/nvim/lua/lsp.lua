local lspconfig = require('lspconfig')

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

lspconfig.rust_analyzer.setup{
  on_attach = require'completion'.on_attach,
  capabilities = capabilities,
  settings = {
    ['rust-analyzer'] = {
      procMacro = {
        enable = true,
      }
    },
  }
}


require'lspfuzzy'.setup{}
