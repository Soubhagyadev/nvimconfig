# Complete Installation Guide

This document provides comprehensive, step-by-step instructions for installing and configuring this Neovim setup on Windows.

## 1. System Prerequisites

Before proceeding with the Neovim configuration, you must ensure that your system has the proper dependencies installed. Since this configuration relies heavily on Mason to automatically install Language Servers (LSP) and formatters, the underlying runtimes must be present on your Windows environment.

### Core Dependencies
* **Neovim (v0.10.0 or higher)**: The core editor.
* **Git**: Required by the `lazy.nvim` package manager to download and update plugins.
* **Node.js & NPM**: Required by Mason to install web-based Language Servers (HTML, CSS, JSON) and formatters (like Prettier).
* **A C Compiler**: Required by Neovim's `nvim-treesitter` plugin to compile syntax highlighting parsers. On Windows, using GCC via MSYS2 or MinGW is highly recommended.
* **Ripgrep**: Required by the Telescope plugin for blazing-fast file and text searching across your projects.
* **A Nerd Font**: Required for rendering the file icons inside Neovim, NvimTree, and the command prompt. (e.g., JetBrainsMono Nerd Font).

### Language-Specific Dependencies
Because this configuration explicitly optimizes the experience for specific languages, you must have their local toolchains installed:
* **Python 3 & Pip**: Required for the `pyright` Language Server, and the `black` and `ruff` formatters.
* **Rust & Cargo**: Required for native `rust-analyzer` integration.
* **Dart & Flutter SDK**: Required for `flutter-tools.nvim` to properly provide widget guides and closing tags.

---

## 2. Backup Existing Configurations

If you have used Neovim on this machine before, you must move your old configurations out of the way. Neovim stores configuration in `LOCALAPPDATA` on Windows.

Run the following commands in PowerShell to create backups:

```powershell
# Backup the main configuration folder
Rename-Item -Path "$env:LOCALAPPDATA\nvim" -NewName "nvim.backup" -ErrorAction SilentlyContinue

# Backup Neovim's data cache (where old plugins and state are stored)
Rename-Item -Path "$env:LOCALAPPDATA\nvim-data" -NewName "nvim-data.backup" -ErrorAction SilentlyContinue
```

---

## 3. Clone This Repository

With a clear environment, download this configuration folder from GitHub directly into the path where Neovim expects to find its settings.

```powershell
git clone https://github.com/Soubhagyadev/nvimconfig.git "$env:LOCALAPPDATA\nvim"
```

---

## 4. Initializing Neovim

At this point, the configuration is successfully downloaded. Now, you need to launch Neovim so that `lazy.nvim` (the plugin manager) can bootstrap itself.

1. Open a new PowerShell window.
2. Type `nvim` and press Enter.

Upon opening, you will see a loading screen as `lazy.nvim` automatically hooks into Git and downloads NvChad, the theme, and all the Lua plugins defined in this repository. 

### Important Final Step: Mason Setup

Once the `lazy.nvim` window completes installing everything:
1. Close the Lazy window by pressing `q`.
2. Neovim will automatically begin running Mason in the background. It will look for your installed dependencies (NPM, Pip, Cargo) and begin downloading the formatters (e.g., `black`, `ruff`, `rustfmt`) and LSPs (e.g., `pyright`, `clangd`).
3. You can monitor the progress of these installations by typing the command `:Mason` and pressing Enter.
4. Wait for all background installations to report a successful state before closing Neovim.

Once Mason is finished, restart Neovim completely for all changes and servers to properly take effect.

---

## 5. Terminal Profile Configuration (Optional)

If you would like to use the bundled PowerShell Power-User profile to gain access to native Vi-mode, Zoxide, Oh-My-Posh, and other terminal utilities:

1. Locate your PowerShell profile by typing `Write-Output $PROFILE` into PowerShell.
2. Copy the contents of the `powershell_config/Microsoft.PowerShell_profile.ps1` file found inside this repository.
3. Paste them into your official `$PROFILE` file path.
4. Ensure you have installed the CLI utilities referenced in the profile via a package manager like Chocolatey or Scoop (e.g., `zoxide`, `oh-my-posh`, `lsd`, `yazi`, `bat`).
