<div align="center">
  <img src="https://neovim.io/logos/neovim-mark-flat.png" alt="Neovim Logo" width="100"/>
  <h1>My Windows Neovim Config</h1>
  <p><i>A hyper-optimized, visually stunning, and highly productive Neovim configuration tailored specifically for <b>Windows & PowerShell</b>. Built on top of NvChad.</i></p>

  <p align="center">
    <a href="https://neovim.io/"><img src="https://img.shields.io/badge/Neovim-0.10+-blue.svg?style=for-the-badge&logo=neovim" alt="Neovim"></a>
    <a href="https://microsoft.com/powershell"><img src="https://img.shields.io/badge/Windows-PowerShell%205.1-blue?style=for-the-badge&logo=windows" alt="PowerShell"></a>
    <a href="https://github.com/NvChad/NvChad"><img src="https://img.shields.io/badge/Powered%20By-NvChad%20v2.5-green.svg?style=for-the-badge" alt="NvChad"></a>
  </p>
</div>

<br/>

## Core Features

| Feature | My Config | Vanilla Neovim | NvChad Base |
| :--- | :--- | :--- | :--- |
| **Theme & UI** | Flexoki & Nvdash | None | Catppuccin |
| **Performance** | Blazing Fast | Fast | Fast |
| **Smooth UX** | Smear Cursor UI | Basic CLI | Basic |
| **Auto-Format** | Conform (format-on-save) | Manual Setup | Conform (manual) |
| **Commenting** | `Comment.nvim` (Block `gb`) | Native `gc` | Native `gc` |
| **OS Integration** | Windows Zero-Profile | Cross-Platform | Cross-Platform |
| **Rust Parsing** | Tuned rust-analyzer | Basic LSP | Basic LSP |
| **Dart / Flutter** | Native Widget Guides | None | None |

### Language Mastery

Designed as a multi-purpose powerhouse, featuring deeply-integrated experiences for:
- **Rust**: Native `rust-analyzer` optimizations, removing full `cargo check` lag with fine-tuned directory exclusion.
- **Flutter & Dart**: Deep integration with `flutter-tools.nvim`, VSCode-like closing tags, and widget guides.
- **Python**: Automatic linting and formatting via `Black` & `Ruff`.
- **C/C++**: `clangd` with inlay hints setup through `clangd_extensions.nvim`.
- **Web**: HTML, CSS, and Lua Language Server optimizations strictly scoped.
- **Markdown**: Fully rendered rich markdown (`render-markdown.nvim`).

_<details>_
_<summary>**Advanced: Smart C/C++/Rust Auto-Comments**</summary>_

> Contains custom Lua `CursorMovedI` callbacks to intelligently continue block comments `//` **only** if the previous 2 lines were also comments. No more accidental auto-comments when writing single-line annotations!
_</details>_

---

## Unique Keybindings

This setup utilizes an **Inverted Movement mapping**, designed for custom ergonomics:

| Key | Mode | Action |
| :---: | :---: | :--- |
| <kbd>j</kbd> | `n` / `v` | **Move UP** (Usually `k`) |
| <kbd>k</kbd> | `n` / `v` | **Move DOWN** (Usually `j`) |
| <kbd>;</kbd> | `n` | Quick enter command mode (`:` replacement) |
| <kbd>j</kbd> + <kbd>k</kbd> | `i` | Exit Insert Mode (Escape) |
| <kbd>Alt</kbd> + <kbd>j</kbd> / <kbd>k</kbd> | `n` / `v` | Move current line(s) Up / Down |
| <kbd>Ctrl</kbd> + <kbd>j</kbd> / <kbd>k</kbd> | `n` | Jump to previous / next line end |
| <kbd>Ctrl</kbd> + <kbd>n</kbd> | `n` | Toggle NvimTree explorer |

_Note: The inverted `<kbd>j</kbd>` & `<kbd>k</kbd>` bindings are consistently translated into Telescope file searches and the Nvdash dashboard menus!_

---

## Installation & Setup

> **Note:** These instructions are for Windows utilizing PowerShell.

### 1. Requirements
* Neovim **0.10+**
* [Git](https://git-scm.com/) installed
* [Ripgrep](https://github.com/BurntSushi/ripgrep) (for Telescope searches)
* A [Nerd Font](https://www.nerdfonts.com/) installed and set in your terminal *(e.g. JetBrainsMono Nerd Font)*
* C Compiler (e.g. `gcc` via MSYS2 / MinGW)

### 2. Backup existing config
If you already had a configuration, back it up first!
```powershell
Rename-Item -Path "$env:LOCALAPPDATA\nvim" -NewName "nvim.bak"
Rename-Item -Path "$env:LOCALAPPDATA\nvim-data" -NewName "nvim-data.bak"
```

### 3. Clone this repository
```powershell
git clone <YOUR-REPO-LINK-HERE> $env:LOCALAPPDATA\nvim
```

### 4. Run Neovim
```powershell
nvim
```
> Wait a moment! `lazy.nvim` will automatically download and install `NvChad` and all configured plugins. Ensure Mason finishes downloading your LSPs and formatters!

---

## Windows-Specific Tweaks Inside
This configuration fundamentally respects the Windows terminal quirks:
- **Zero-Profile PowerShell Integration:** Loads powershell execution commands at blink speed without invoking your bulky `$PROFILE` or logos.
- **UTF-8 Piping:** Fixes shell quotation and piping natively through `vim.opt.shellredir` for flawless `!` execution and formatting.

<br/>

## Terminal Power-User Profile
Also included in this repository is my ultimate PowerShell Profile, specifically designed for Neovim power-users. You can find it inside the [`powershell_config/`](powershell_config/) directory.

**Profile Highlights:**
- Oh My Posh (`cinnamon` theme) Integration
- Vi-Mode natively applied to your typing prompt
- Zoxide (`z`) and FZF (`Ctrl+r` command history search)
- Advanced commands integrated natively like `yazi`, `lsd`, and `bat`
- `gcc` compilation and execution shortcut (`runc`)
- Dynamic environment variable reload using `refreshenv` (no terminal restart required!)
