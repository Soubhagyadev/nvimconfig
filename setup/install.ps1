<#
.SYNOPSIS
Installs the Windows Neovim Configuration safely.

.DESCRIPTION
This script checks for critically required dependencies (like NodeJS, NPM, Git, Neovim),
backs up existing configuration files, and seamlessly copies this configuration into
the local AppData directory.
#>

$ErrorActionPreference = "Stop"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  Windows Neovim Config Installer" -ForegroundColor Cyan
Write-Host "=========================================`n" -ForegroundColor Cyan

# 1. Dependency Checks
Write-Host "--- Checking Prerequisites ---" -ForegroundColor Cyan

$criticalDeps = @("git", "nvim", "node", "npm")
$missingCritical = $false

foreach ($dep in $criticalDeps) {
    if (Get-Command $dep -ErrorAction SilentlyContinue) {
        Write-Host "  [ √ ] $dep found" -ForegroundColor Green
    } else {
        Write-Host "  [ X ] CRITICAL: $dep is missing from PATH" -ForegroundColor Red
        $missingCritical = $true
    }
}

$recommendedDeps = @("gcc", "rg")
foreach ($dep in $recommendedDeps) {
    if (Get-Command $dep -ErrorAction SilentlyContinue) {
        Write-Host "  [ √ ] $dep found" -ForegroundColor Green
    } else {
        Write-Host "  [ ! ] RECOMMENDED: $dep is missing from PATH" -ForegroundColor Yellow
    }
}

if ($missingCritical) {
    Write-Host "`n[ERROR] Installation aborted due to missing critical dependencies." -ForegroundColor Red
    Write-Host "Please ensure NodeJS, NPM, Git, and Neovim are installed before running this script." -ForegroundColor Yellow
    Write-Host "Mason relies heavily on NodeJS to bootstrap formatters and Language Servers." -ForegroundColor Yellow
    exit 1
}

# 2. Paths
$destNvim = Join-Path $env:LOCALAPPDATA "nvim"
$destData = Join-Path $env:LOCALAPPDATA "nvim-data"
$sourceDir = Split-Path -Parent $PSScriptRoot

# Avoid copying over ourselves if already executing inside LOCALAPPDATA
if ($sourceDir -eq $destNvim) {
    Write-Host "`n[INFO] You are already executing from the destination directory ($destNvim)." -ForegroundColor Green
    Write-Host "Configuration is already placed correctly!" -ForegroundColor Green
    exit 0
}

# 3. Backups
Write-Host "`n--- Backing up existing configurations ---" -ForegroundColor Cyan
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

if (Test-Path $destNvim) {
    $bakNvim = "$destNvim.backup_$timestamp"
    Write-Host "Backing up nvim config to: $bakNvim" -ForegroundColor Yellow
    Rename-Item -Path $destNvim -NewName (Split-Path $bakNvim -Leaf) -Force
}

if (Test-Path $destData) {
    $bakData = "$destData.backup_$timestamp"
    Write-Host "Backing up nvim data cache to: $bakData" -ForegroundColor Yellow
    Rename-Item -Path $destData -NewName (Split-Path $bakData -Leaf) -Force
}

# 4. Install
Write-Host "`n--- Installing Configuration ---" -ForegroundColor Cyan
Write-Host "Copying files to $destNvim..." -ForegroundColor Blue

# Create destination
New-Item -ItemType Directory -Force -Path $destNvim | Out-Null

# Copy files, excluding Git and backup folders
Get-ChildItem -Path $sourceDir -Exclude ".git", ".github", "*.backup*" | Copy-Item -Destination $destNvim -Recurse -Force

Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host " Installation Complete!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Now run 'nvim' in your terminal! Lazy.nvim and Mason will"
Write-Host "automatically download all required plugins and LSPs."
