# Userland-only installation for Windows.
#
# Description:
#   Install dotfiles on Windows using userland-only tools:
#   - Scoop (userland by default)
#   - winget with --scope user
#   - Direct binary downloads to %USERPROFILE%\bin
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File make/install_mswin.ps1
#
# Notes:
# - Native Windows shell init differs across PowerShell profiles.
# - For a better experience, consider using WSL and run `./make/install.bash`.
#

$ErrorActionPreference = "Stop"

Write-Host "Windows install (userland-only)" -ForegroundColor Green

# Check for Scoop
$hasScoop = $false
if (Get-Command scoop -ErrorAction SilentlyContinue) {
    $hasScoop = $true
    Write-Host "INFO: Scoop found" -ForegroundColor Cyan
} else {
    Write-Host "INFO: Scoop not found. Install it from https://scoop.sh if desired." -ForegroundColor Yellow
}

# Check for winget
$hasWinget = $false
if (Get-Command winget -ErrorAction SilentlyContinue) {
    $hasWinget = $true
    Write-Host "INFO: winget found" -ForegroundColor Cyan
} else {
    Write-Host "INFO: winget not found." -ForegroundColor Yellow
}

# Create user bin directory
$userBin = "$env:USERPROFILE\bin"
if (-not (Test-Path $userBin)) {
    New-Item -ItemType Directory -Path $userBin | Out-Null
    Write-Host "Created $userBin" -ForegroundColor Green
}

# Add to PATH if not already present
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$userBin*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$userBin", "User")
    Write-Host "Added $userBin to user PATH" -ForegroundColor Green
}

Write-Host ""
Write-Host "Windows install completed (userland-only)." -ForegroundColor Green
Write-Host "Recommended: use WSL for full Linux/macOS shell experience." -ForegroundColor Yellow

