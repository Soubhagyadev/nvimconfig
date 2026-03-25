#!/usr/bin/env bash
# ==============================================================================
# Linux Neovim Config Installer
# Automatically installs prerequisites and deploys the configuration.
# Supports: Ubuntu/Debian, Fedora/RHEL, Arch Linux
# ==============================================================================

set -e

REPO_URL="https://github.com/Soubhagyadev/nvimconfig.git"
NVIM_CONFIG_DIR="$HOME/.config/nvim"
NVIM_DATA_DIR="$HOME/.local/share/nvim"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

print_header() {
    echo -e "\n${CYAN}==========================================${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}==========================================${NC}\n"
}

print_ok()      { echo -e "  ${GREEN}[ OK ]${NC} $1"; }
print_warn()    { echo -e "  ${YELLOW}[ !! ]${NC} $1"; }
print_fail()    { echo -e "  ${RED}[FAIL]${NC} $1"; }
print_info()    { echo -e "  ${CYAN}[INFO]${NC} $1"; }

# --- Detect Package Manager ---
detect_pkg_manager() {
    if command -v apt &>/dev/null; then
        PKG_MANAGER="apt"
        PKG_INSTALL="sudo apt install -y"
        PKG_UPDATE="sudo apt update -y"
    elif command -v dnf &>/dev/null; then
        PKG_MANAGER="dnf"
        PKG_INSTALL="sudo dnf install -y"
        PKG_UPDATE="sudo dnf check-update || true"
    elif command -v pacman &>/dev/null; then
        PKG_MANAGER="pacman"
        PKG_INSTALL="sudo pacman -S --noconfirm"
        PKG_UPDATE="sudo pacman -Sy"
    else
        echo -e "${RED}Could not detect a supported package manager (apt, dnf, pacman).${NC}"
        echo -e "Please install dependencies manually and re-run this script."
        exit 1
    fi
    print_info "Detected package manager: ${BOLD}$PKG_MANAGER${NC}"
}

# --- Install a package if missing ---
ensure_installed() {
    local cmd_name="$1"
    local pkg_name="${2:-$1}"

    if command -v "$cmd_name" &>/dev/null; then
        print_ok "$cmd_name is already installed"
        return 0
    fi

    print_warn "$cmd_name not found. Installing $pkg_name..."
    $PKG_INSTALL "$pkg_name"

    if command -v "$cmd_name" &>/dev/null; then
        print_ok "$cmd_name installed successfully"
    else
        print_fail "Failed to install $cmd_name. Please install it manually."
        exit 1
    fi
}

# --- Install Neovim (latest stable from GitHub releases) ---
install_neovim() {
    if command -v nvim &>/dev/null; then
        local nvim_version
        nvim_version=$(nvim --version | head -1)
        print_ok "Neovim is already installed ($nvim_version)"
        return 0
    fi

    print_warn "Neovim not found. Installing latest stable release..."

    if [ "$PKG_MANAGER" = "pacman" ]; then
        $PKG_INSTALL neovim
    else
        # Download the latest stable AppImage for maximum compatibility
        local nvim_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage"
        local nvim_dest="/usr/local/bin/nvim"

        print_info "Downloading Neovim AppImage..."
        sudo curl -Lo "$nvim_dest" "$nvim_url"
        sudo chmod +x "$nvim_dest"
    fi

    if command -v nvim &>/dev/null; then
        print_ok "Neovim installed successfully ($(nvim --version | head -1))"
    else
        print_fail "Neovim installation failed. Please install manually."
        exit 1
    fi
}

# --- Install Node.js via NodeSource if missing ---
install_nodejs() {
    if command -v node &>/dev/null && command -v npm &>/dev/null; then
        print_ok "Node.js is already installed ($(node --version))"
        print_ok "NPM is already installed ($(npm --version))"
        return 0
    fi

    print_warn "Node.js / NPM not found. Installing via NodeSource..."

    if [ "$PKG_MANAGER" = "apt" ]; then
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt install -y nodejs
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo -E bash -
        sudo dnf install -y nodejs
    elif [ "$PKG_MANAGER" = "pacman" ]; then
        $PKG_INSTALL nodejs npm
    fi

    if command -v node &>/dev/null && command -v npm &>/dev/null; then
        print_ok "Node.js installed successfully ($(node --version))"
        print_ok "NPM installed successfully ($(npm --version))"
    else
        print_fail "Node.js installation failed. Please install manually."
        exit 1
    fi
}

# ==============================================================================
# MAIN
# ==============================================================================

print_header "Linux Neovim Config Installer"

# Step 1: Detect system
detect_pkg_manager
echo ""
print_info "Updating package index..."
$PKG_UPDATE
echo ""

# Step 2: Install all prerequisites
print_header "Installing Prerequisites"

ensure_installed "git" "git"
ensure_installed "curl" "curl"
ensure_installed "unzip" "unzip"
install_neovim
install_nodejs
ensure_installed "rg" "ripgrep"
ensure_installed "gcc" "gcc"
ensure_installed "make" "make"

# Step 3: Backup existing config
print_header "Backing Up Existing Configuration"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

if [ -d "$NVIM_CONFIG_DIR" ]; then
    BACKUP_CONFIG="${NVIM_CONFIG_DIR}.backup_${TIMESTAMP}"
    print_warn "Existing nvim config found. Backing up to: $BACKUP_CONFIG"
    mv "$NVIM_CONFIG_DIR" "$BACKUP_CONFIG"
else
    print_ok "No existing nvim config found. Skipping backup."
fi

if [ -d "$NVIM_DATA_DIR" ]; then
    BACKUP_DATA="${NVIM_DATA_DIR}.backup_${TIMESTAMP}"
    print_warn "Existing nvim data found. Backing up to: $BACKUP_DATA"
    mv "$NVIM_DATA_DIR" "$BACKUP_DATA"
else
    print_ok "No existing nvim data found. Skipping backup."
fi

# Step 4: Clone the repository
print_header "Cloning Configuration"

print_info "Cloning from $REPO_URL..."
git clone "$REPO_URL" "$NVIM_CONFIG_DIR"
print_ok "Configuration cloned to $NVIM_CONFIG_DIR"

# Step 5: Remove Windows-specific shell settings from init.lua
print_header "Adapting Configuration for Linux"

INIT_FILE="$NVIM_CONFIG_DIR/init.lua"

if [ -f "$INIT_FILE" ]; then
    # Remove the PowerShell block (lines containing powershell, shellcmdflag, shellquote, shellxquote, shellredir, shellpipe)
    sed -i '/^-- Use PowerShell/d' "$INIT_FILE"
    sed -i '/vim.opt.shell = "powershell.exe"/d' "$INIT_FILE"
    sed -i '/^-- Clean startup/d' "$INIT_FILE"
    sed -i '/vim.opt.shellcmdflag/d' "$INIT_FILE"
    sed -i '/^-- Fix Windows quoting/d' "$INIT_FILE"
    sed -i '/vim.opt.shellquote/d' "$INIT_FILE"
    sed -i '/vim.opt.shellxquote/d' "$INIT_FILE"
    sed -i '/^-- Proper output handling/d' "$INIT_FILE"
    sed -i '/vim.opt.shellredir/d' "$INIT_FILE"
    sed -i '/vim.opt.shellpipe/d' "$INIT_FILE"
    print_ok "Removed Windows-specific shell options from init.lua"
fi

# Remove powershell terminal config from chadrc.lua
CHADRC_FILE="$NVIM_CONFIG_DIR/lua/chadrc.lua"

if [ -f "$CHADRC_FILE" ]; then
    sed -i '/shell = "powershell"/d' "$CHADRC_FILE"
    sed -i '/M.ui = {/,/^}/{ /M.ui/d; /terminal/d; /^}/d; }' "$CHADRC_FILE"
    print_ok "Removed PowerShell terminal config from chadrc.lua"
fi

# Step 6: Done
print_header "Installation Complete"

echo -e "Your Neovim configuration has been installed to:"
echo -e "  ${BOLD}$NVIM_CONFIG_DIR${NC}"
echo ""
echo -e "Next steps:"
echo -e "  1. Run ${BOLD}nvim${NC} in your terminal."
echo -e "  2. Wait for lazy.nvim to finish installing all plugins."
echo -e "  3. Run ${BOLD}:Mason${NC} inside Neovim and wait for LSPs and formatters to install."
echo -e "  4. Restart Neovim once everything completes."
echo ""
echo -e "${GREEN}Enjoy your new setup!${NC}"
