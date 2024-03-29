local lspconfig = require('lspconfig')

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

lspconfig.rust_analyzer.setup{
  on_attach = require'completion'.on_attach,
  capabilities = capabilities,
  settings = {
    ['rust-analyzer'] = {
      checkOnSave = {
        extraArgs = {
          '--target-dir', '/home/cecile/repos/target'
        },
      },
      procMacro = {
        enable = true,
      },
    },
  }
}

vim.lsp.handlers["textDocument/publishDiagnostics"] = function() end

require'lspfuzzy'.setup{}
