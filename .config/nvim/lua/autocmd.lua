vim.api.nvim_create_autocmd({"BufReadPre", "BufNewFile"}, {
  pattern = "*",
  callback = function()
    local max_filesize = 1 * 1024 * 1024 -- 1MB
    local file = vim.fn.expand("<afile>")
    if vim.fn.getfsize(file) > max_filesize then
      vim.opt_local.foldmethod = "manual"
    end
  end,
})
