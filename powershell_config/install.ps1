<#
.SYNOPSIS
Installs the Power-User PowerShell Profile to the current user's system.

.DESCRIPTION
This script backs up your existing $PROFILE if one exists, copies the custom
Microsoft.PowerShell_profile.ps1 into the correct location, and provides status
warnings if recommended CLI tools (like zoxide, fzf, or oh-my-posh) are not found.
#>

$ErrorActionPreference = "Stop"
$sourceProfile = Join-Path -Path $PSScriptRoot -ChildPath "Microsoft.PowerShell_profile.ps1"
$targetProfile = $PROFILE

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  Power-User Profile Installer" -ForegroundColor Cyan
Write-Host "=========================================`n" -ForegroundColor Cyan

# 1. Verify Source File
if (-not (Test-Path -Path $sourceProfile)) {
    Write-Host "[ERROR] Could not find the source profile at: $sourceProfile" -ForegroundColor Red
    Write-Host "Please ensure you run this script from inside the repository folder." -ForegroundColor Yellow
    exit 1
}

# 2. Ensure the Profile Directory Exists
$profileDir = Split-Path -Path $targetProfile
if (-not (Test-Path -Path $profileDir)) {
    Write-Host "[INFO] Creating PowerShell profile directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
}

# 3. Backup Existing Profile safely
if (Test-Path -Path $targetProfile) {
    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $backupName = "Microsoft.PowerShell_profile.backup_$timestamp.ps1"
    $backupPath = Join-Path -Path $profileDir -ChildPath $backupName
    
    Write-Host "[INFO] Existing profile detected." -ForegroundColor Yellow
    Write-Host "[INFO] Creating backup at: $backupPath" -ForegroundColor Yellow
    Copy-Item -Path $targetProfile -Destination $backupPath -Force
}

# 4. Copy the New Profile over
Write-Host "[OK] Installing new profile configuration..." -ForegroundColor Green
Copy-Item -Path $sourceProfile -Destination $targetProfile -Force

# 5. Dependency Audit Check
Write-Host "`n--- Checking Required System Dependencies ---" -ForegroundColor Cyan

$dependencies = @("oh-my-posh", "zoxide", "fzf", "lsd", "bat", "yazi", "gcc", "nvim")
$missingDeps = @()

foreach ($dep in $dependencies) {
    if (Get-Command $dep -ErrorAction SilentlyContinue) {
        Write-Host "  [ √ ] $dep" -ForegroundColor Green
    } else {
        Write-Host "  [ X ] $dep (Missing)" -ForegroundColor Red
        $missingDeps += $dep
    }
}

if ($missingDeps.Count -gt 0) {
    Write-Host "`n[WARNING] Your system is missing some tools used by this profile!" -ForegroundColor Yellow
    Write-Host "For the complete experience, we strongly recommend installing them."
    Write-Host "You can quickly install the missing CLI tools via Scoop:" -ForegroundColor Cyan
    Write-Host "  scoop install $($missingDeps -join ' ')"
    Write-Host "Or via Chocolatey:" -ForegroundColor Cyan
    Write-Host "  choco install $($missingDeps -join ' ')"
} else {
    Write-Host "`n[SUCCESS] All dependencies are already installed on your system!" -ForegroundColor Green
}

Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host " Complete! Please restart your terminal." -ForegroundColor Green
Write-Host " Or run: . `$PROFILE" -ForegroundColor Gray
Write-Host "=========================================" -ForegroundColor Cyan
