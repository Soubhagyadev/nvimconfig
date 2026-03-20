-- Dart indentation settings for Flutter development
-- This ensures proper bracket alignment when nesting widgets

vim.api.nvim_create_autocmd("FileType", {
  pattern = "dart",
  callback = function()
    -- Set Dart-specific indentation (2 spaces like VSCode/Flutter convention)
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true

    -- Use cindent for better bracket alignment
    vim.opt_local.cindent = true
    vim.opt_local.smartindent = true
    vim.opt_local.autoindent = true

    -- Disable treesitter indent for dart (it can cause issues with bracket alignment)
    vim.opt_local.indentexpr = ""

    -- Configure cindent options for proper Flutter widget nesting
    -- This helps with bracket alignment
    vim.opt_local.cinoptions = "j1,J1,l1,g0,N-s,(0,W4"
  end,
})
