# Sync Windows configs from /etc/nixos/dotfiles/windows
param(
    [switch]$BackupOnly
)

$ErrorActionPreference = "Stop"
$src = Split-Path -Parent $MyInvocation.MyCommand.Path
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"

$targets = @(
    @{ Src = "$src\glazewm\config.yaml"; Dst = "$HOME\.glzr\glazewm\config.yaml" },
    @{ Src = "$src\zebar\settings.json"; Dst = "$HOME\.glzr\zebar\settings.json" },
    @{ Src = "$src\windows-terminal\settings.json"; Dst = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" },
    @{ Src = "$src\powershell\Microsoft.PowerShell_profile.ps1"; Dst = "$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" },
    @{ Src = "$src\vscode\settings.json"; Dst = "$env:APPDATA\Code\User\settings.json" },
    @{ Src = "$src\nvim\init.lua"; Dst = "$env:LOCALAPPDATA\nvim\init.lua" },
    @{ Src = "$src\ssh\config"; Dst = "$HOME\.ssh\config" }
)

foreach ($t in $targets) {
    $parent = Split-Path -Parent $t.Dst
    if (!(Test-Path $parent)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
    if (Test-Path $t.Dst) {
        Copy-Item -Force $t.Dst "$($t.Dst).bak-$stamp"
    }
    if (-not $BackupOnly) {
        Copy-Item -Force $t.Src $t.Dst
        Write-Host "Synced -> $($t.Dst)" -ForegroundColor Green
    }
}

if (-not $BackupOnly) {
    $zDst = "$HOME\.glzr\zebar\dyna-mocha"
    New-Item -ItemType Directory -Force -Path "$zDst\vendor" | Out-Null
    Copy-Item -Recurse -Force "$src\zebar\dyna-mocha\*" $zDst
    Write-Host "Synced -> $zDst" -ForegroundColor Green
    if (Get-Command glazewm -ErrorAction SilentlyContinue) {
        glazewm command wm-reload-config | Out-Null
        Write-Host "Reloaded GlazeWM." -ForegroundColor Magenta
    }
}
