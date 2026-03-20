-- configs/lspconfig.lua
-- Updated for Neovim 0.11+ and nvim-lspconfig 0.11+

local nvlsp = require "nvchad.configs.lspconfig"

-- Use NvChad's standard setup variables
local on_attach = nvlsp.on_attach
local on_init = nvlsp.on_init
local capabilities = nvlsp.capabilities

-- Configure pyright (Python LSP)
vim.lsp.config("pyright", {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
})

-- Configure lua_ls (Lua LSP)
vim.lsp.config("lua_ls", {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = {
          vim.fn.expand("$VIMRUNTIME/lua"),
          vim.fn.expand("$VIMRUNTIME/lua/vim/lsp"),
          vim.fn.stdpath("data") .. "/lazy/ui/nvchad_types",
          vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy",
        },
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
    },
  },
})

-- Configure HTML LSP
vim.lsp.config("html", {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
})

-- Configure CSS LSP
vim.lsp.config("cssls", {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
})

-- Configure clangd (C/C++ LSP)
local clangd_capabilities = vim.tbl_deep_extend("force", capabilities, { offsetEncoding = { "utf-16" } })
vim.lsp.config("clangd", {
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)
  end,
  on_init = on_init,
  capabilities = clangd_capabilities,
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
  },
})

-- Configure Rust Analyzer
vim.lsp.config("rust_analyzer", {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  settings = {
    ["rust-analyzer"] = {
      -- Use cargo check instead of clippy for faster live feedback
      check = {
        command = "check",
      },
      cargo = {
        -- Don't compile ALL feature combinations (this was the main lag culprit!)
        allFeatures = false,
        -- Exclude the target/ build directory from being watched/indexed
        extraEnv = { CARGO_TARGET_DIR = "target" },
      },
      -- Exclude target/ and other heavy dirs from file watching entirely
      files = {
        excludeDirs = {
          "target",
          ".git",
          "node_modules",
        },
        watcher = "server", -- Use rust-analyzer's own watcher instead of the LSP client
      },
      -- Disable build scripts on startup (they trigger full cargo builds!)
      rust = {
        analyzeTargetDirectory = false,
      },
      procMacro = {
        enable = true,
      },
    },
  },
})

-- Enable LSP servers
-- NOTE: dartls is configured by flutter-tools.nvim, do NOT add it here!
vim.lsp.enable({ "pyright", "html", "cssls", "rust_analyzer", "lua_ls", "clangd" })