return {
  -- 0. Nvim Tree
  {
    "nvim-tree/nvim-tree.lua",
    opts = require "configs.nvimtree",
  },

  -- 1. Formatting (Conform)
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- Format on save
    opts = require "configs.conform",
  },

  -- 2. Mason (Package manager for LSP servers, formatters, linters)
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "black",    -- Python Formatter
        "ruff",     -- Python Linter
        "rustfmt",  -- Rust Formatter
      },
    },
  },

  -- 3. Mason-LSPConfig (Bridge between mason and lspconfig)
  -- This automates the installation of certain LSP servers
  {
    "mason-org/mason-lspconfig.nvim",
    event = "User FilePost", -- Optimize: Load only after a file is actually opened to speed up Neovim boot
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("mason-lspconfig").setup {
        ensure_installed = { "pyright", "html", "cssls", "rust_analyzer", "lua_ls", "clangd" },
        automatic_enable = true,
      }
    end,
  },

  -- 4. LSP Config
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
    end,
  },

  -- 5. Completion (Blink)
  { import = "nvchad.blink.lazyspec" },

  -- 6. Treesitter (Syntax Highlighting)
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim", "lua", "vimdoc", "html", "css", "python", "dart", "rust", "toml",
        "markdown", "markdown_inline", "c", "cpp"
      },
    },
  },

  -- 6.5 Render Markdown
  {
    "MeanderingProgrammer/render-markdown.nvim",
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown", "norg", "rmd", "org" },
    opts = {},
  },

  -- 7. Flutter Tools (Dart/Flutter development with closing tags & widget guides)
  -- NOTE: Do NOT configure dartls in lspconfig when using this plugin!
  -- This plugin setups dartls, flutter commands, and UI decorations for flutter
  {
    "nvim-flutter/flutter-tools.nvim",
    ft = "dart", -- Optimize: Only load this heavy plugin when opening a Dart file
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim",  -- Better UI for selections
    },
    config = function()
      local nvlsp = require "nvchad.configs.lspconfig"
      require("flutter-tools").setup {
        ui = {
          border = "rounded",
          notification_style = "native",
        },
        decorations = {
          statusline = {
            app_version = true,
            device = true,
          },
        },
        -- Widget guides (vertical lines showing widget structure)
        widget_guides = {
          enabled = true,
        },
        -- Closing tags (// MaterialApp, // Scaffold, etc.)
        closing_tags = {
          highlight = "Comment",  -- Use Comment highlight for subtle appearance
          prefix = "// ",         -- Prefix for closing tag (like VSCode)
          priority = 10,
          enabled = true,
        },
        dev_log = {
          enabled = true,
          notify_errors = true,
          open_cmd = "15split",
        },
        lsp = {
          on_attach = nvlsp.on_attach,
          capabilities = nvlsp.capabilities,
          settings = {
            showTodos = true,
            completeFunctionCalls = true,
            renameFilesWithClasses = "prompt",
            enableSnippets = true,
            updateImportsOnRename = true,
          },
        },
      }
    end,
  },

  -- 8. Dart Vim Plugin (Better Dart syntax, indentation, and formatting)
  -- Provides basic Vim configurations (like 2-space indentation) tailored for Dart
  {
    "dart-lang/dart-vim-plugin",
    ft = "dart", -- Optimize: Only load when opening a Dart file
    config = function()
      -- VSCode-like 2-space indentation
      vim.g.dart_style_guide = 2
      -- Auto-format on save using dart format
      vim.g.dart_format_on_save = 1
      -- Proper indentation with trailing commas
      vim.g.dart_trailing_comma_indent = true
    end,
  },

  -- 9. Smear Cursor (Animate cursor with a smear effect)
  {
    "sphamba/smear-cursor.nvim",
    lazy = false, -- Load automatically
    opts = {
      smear_between_neighbor_lines = true,
      smear_between_buffers = true,
      stiffness = 0.6,               -- 0.6 [0, 1]
      trailing_stiffness = 0.3,      -- 0.45 [0, 1]
      distance_stop_animating = 0.1, -- 0.1 > 0
    },
  },

  -- 10. Clangd extensions for better C/C++ experience
  {
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
    opts = {
      inlay_hints = {
        inline = vim.fn.has("nvim-0.10") == 1,
      },
    },
    config = function(_, opts)
      require("clangd_extensions").setup(opts)
    end,
  },

  -- 11. Telescope keymap override for inverted j/k
  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, conf)
      local actions = require "telescope.actions"
      conf.defaults = conf.defaults or {}
      conf.defaults.mappings = vim.tbl_deep_extend("force", conf.defaults.mappings or {}, {
        i = {
          ["<C-j>"] = actions.move_selection_previous,
          ["<C-k>"] = actions.move_selection_next,
        },
        n = {
          ["j"] = actions.move_selection_previous,
          ["k"] = actions.move_selection_next,
        },
      })
      return conf
    end,
  },
}