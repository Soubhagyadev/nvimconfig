# ==============================================================================
# PowerShell Power-User Profile
# ==============================================================================
# 0. Adding Refreshenv
Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1

# 1. Visual Enhancements (Icons & Formatting)
Import-Module -Name Terminal-Icons

# 2. Command Prediction & Vi Mode (Neovim Power User)
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle InlineView
Set-PSReadLineOption -Colors @{ InlinePrediction = "#8E8E8E" }

# Enable Neovim/Vi bindings in the terminal (Press ESC to enter normal mode)
Set-PSReadLineOption -EditMode Vi
Set-PSReadLineOption -ViModeIndicator Cursor

# 3. Prompt Configuration (Oh My Posh - cinnamon Theme)
oh-my-posh init pwsh --config "~/.config/oh-my-posh/cinnamon.omp.json" | Invoke-Expression

# 4. Aliases & Tools
Set-Alias -Name v -Value nvim
Set-Alias -Name vi -Value nvim

# --- LSD (Beautiful List Viewer) ---
function ls   { lsd $args }
function ll   { lsd -l $args }
function la   { lsd -a $args }
function tree { lsd --tree }

# 5. Advanced Key Bindings
# Automatically load the previous command on Ctrl+w
Set-PSReadLineKeyHandler -Key Ctrl+w -Function PreviousHistory

function runc ($file) {
    $exe = [System.IO.Path]::GetFileNameWithoutExtension($file)
    gcc $file -o "$exe.exe"
    if ($LASTEXITCODE -eq 0) {
        & ".\$exe.exe"
    }
}

# --- Cleanup Utility (Purge .exe artifacts) ---
function removexe {
    Remove-Item *.exe -ErrorAction SilentlyContinue
}

# ==============================================================================
# Terminal Utilities & Extensions
# ==============================================================================

# Fastfetch (Available on demand, type 'fastfetch' to display specs)

# --- Zoxide (Smarter, history-aware CD alternative) ---
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# 3. FZF (Fuzzy finder for command history)
Set-PSReadLineKeyHandler -Key Ctrl+r -ScriptBlock {
    $historyFile = (Get-PSReadLineOption).HistorySavePath
    $command = Get-Content $historyFile | fzf --tac --no-sort --height=40% --layout=reverse --border
    if ($command) {
        [System.Console]::CursorLeft = 0
        [Microsoft.PowerShell.PSConsoleReadLine]::ReplaceLine($command)
        [Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
    }
}

# 4. Bat (Cat clone with syntax highlighting)
# Use `bat <filename>` to view files beautifully.

# 5. Yazi - Blazing fast TUI file manager with Vi motions
# `yy` opens Yazi. Upon exit, your terminal dynamically drops into that directory!
function yy {
    $tmp = [System.IO.Path]::GetTempFileName()
    yazi $args --cwd-file="$tmp"
    if (Test-Path -Path $tmp) {
        $cwd = Get-Content -Path $tmp -Raw
        if ($cwd -and $cwd -ne $PWD.Path) {
            Set-Location -Path $cwd
        }
        Remove-Item -Path $tmp -ErrorAction SilentlyContinue
    }
}

# 6. Ripgrep (rg) & Fd
# Telescope in Neovim will now automatically utilize these for blazing fast file finding!

# 7. Git Delta
# Git diffs are globally configured to be syntax-highlighted and aesthetic inside your terminal natively.