-- lua/plugins/lsp/common.lua
local M = {}

vim.diagnostic.config({
  virtual_text = true,   -- ← must be true (or table) for inline error text
})

vim.api.nvim_create_autocmd("CursorHold", {
  callback = function() vim.diagnostic.open_float(nil, {focus=false}) end
})
-- Make CursorHold fire faster if you like:
vim.o.updatetime = 500

---------------------------------------------------------------------
-- 1. Enhanced client capabilities (completion, snippets, etc.)
---------------------------------------------------------------------
local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
M.capabilities = ok_cmp
  and cmp_lsp.default_capabilities()
  or vim.lsp.protocol.make_client_capabilities()


---------------------------------------------------------------------
-- 2. on_attach: runs AFTER the language server attaches to each buffer
---------------------------------------------------------------------
function M.on_attach(client, bufnr)
  -- Helper for shorter keymap lines
  local function nmap(lhs, rhs, desc)
    if desc then
      desc = "LSP: " .. desc
    end
    vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
  end
  -- Basic navigation & actions
  nmap("gd", vim.lsp.buf.definition,       "[G]oto [D]efinition")
  nmap("gD", vim.lsp.buf.declaration,      "Go to Declaration")
  nmap("gr", vim.lsp.buf.references,       "[G]oto [R]eferences")
  nmap("K",  vim.lsp.buf.hover,            "Hover Documentation")
  nmap("<leader>rn", vim.lsp.buf.rename,   "[R]e[n]ame symbol")
  nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

  -- Auto-format on save (only if the server supports it)
  if client.server_capabilities.documentFormattingProvider then
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function() vim.lsp.buf.format({ bufnr = bufnr }) end,
    })
  end

  -- Example: attach nvim-navic for breadcrumbs (if installed & supported)
  local ok_navic, navic = pcall(require, "nvim-navic")
  if ok_navic and client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
  end
end

return M
