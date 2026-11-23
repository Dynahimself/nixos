[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)

if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (& starship init powershell)
}

if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine -ErrorAction SilentlyContinue
    try {
        Set-PSReadLineOption -EditMode Windows -BellStyle None
        Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue
        Set-PSReadLineOption -Colors @{
            Command            = '#89b4fa'
            Parameter          = '#b4befe'
            Operator           = '#94e2d5'
            Variable           = '#f5c2e7'
            String             = '#a6e3a1'
            Number             = '#fab387'
            Type               = '#f9e2af'
            Comment            = '#6c7086'
            Keyword            = '#cba6f7'
            Error              = '#f38ba8'
            InlinePrediction   = '#585b70'
            Default            = '#cdd6f4'
        }
    } catch {}
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
}

function cshub { wsl -d NixOS -u dyna -- python3 /etc/nixos/tools/cshub/cshub.py @args }
function csh   { cshub @args }
function csa   { cshub agenda @args }
function csc   { cshub cal @args }
function csd   { cshub dash @args }

function fleet {
    try {
        $st = Invoke-RestMethod -Uri 'http://100.68.54.112:8210/api/status' -TimeoutSec 3
        Write-Host ""
        Write-Host "  Fleet Status" -ForegroundColor Magenta -NoNewline
        Write-Host "  (Pi $($st.pi_temp) | RAM $($st.pi_mem) | Backup: $($st.backup))" -ForegroundColor DarkGray
        Write-Host "  ----------------------------------------------------------------" -ForegroundColor DarkGray
        foreach ($n in $st.nodes) {
            $tag = if ($n.online) { "[UP]  " } else { "[DOWN]" }
            $col = if ($n.online) { "Green" } else { "DarkGray" }
            $detail = ($n.detail -replace '\u00b7', '|')
            Write-Host ("  {0} {1,-18} {2,-16} {3}" -f $tag, $n.name, $n.ip, $detail) -ForegroundColor $col
        }
        if ($st.cshub) {
            $h = $st.cshub
            $openCount = if ($h.open_items) { $h.open_items.Count } else { 0 }
            Write-Host ""
            Write-Host ("  CS Hub: {0} open | {1} due cards | {2}d streak | {3}m today" -f $openCount, $h.due_count, $h.streak, $h.today_minutes) -ForegroundColor Cyan
        }
        Write-Host ""
    } catch {
        Write-Host "Fleet API unreachable (100.68.54.112:8210) — check Tailscale." -ForegroundColor Yellow
    }
}

function wake-desktop {
    try {
        $r = Invoke-RestMethod -Method Post -Uri 'http://100.68.54.112:8210/api/wake-desktop' -TimeoutSec 4
        Write-Host $r.message -ForegroundColor Green
    } catch {
        Write-Host "Failed to reach Pi WoL API: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function pi      { ssh raspberrypi @args }
function nas     { ssh nas @args }
function desktop { ssh desktop @args }

function clip-push {
    param([string]$Text)
    if (-not $Text) { $Text = Get-Clipboard -Raw }
    if (-not $Text) { Write-Host "Clipboard is empty." -ForegroundColor Yellow; return }
    try {
        $body = @{ text = $Text; source = "laptop-win" } | ConvertTo-Json -Compress
        $r = Invoke-RestMethod -Method Post -Uri 'http://100.68.54.112:8210/api/clip' -ContentType 'application/json; charset=utf-8' -Body ([System.Text.Encoding]::UTF8.GetBytes($body)) -TimeoutSec 3
        $prev = ($Text -replace '\r?\n', ' ').Trim()
        if ($prev.Length -gt 60) { $prev = $prev.Substring(0, 60) + "..." }
        Write-Host "Pushed $($r.length) chars -> Fleet: $prev" -ForegroundColor Green
    } catch {
        Write-Host "Fleet clip push failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function clip-pull {
    try {
        $c = Invoke-RestMethod -Uri 'http://100.68.54.112:8210/api/clip' -TimeoutSec 3
        if (-not $c.text) { Write-Host "Fleet clipboard is empty." -ForegroundColor Yellow; return }
        Set-Clipboard -Value $c.text
        $prev = ($c.text -replace '\r?\n', ' ').Trim()
        if ($prev.Length -gt 60) { $prev = $prev.Substring(0, 60) + "..." }
        Write-Host "Pulled ($($c.source) @ $($c.updated_at)): $prev" -ForegroundColor Cyan
    } catch {
        Write-Host "Fleet clip pull failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function wm-reload {
    glazewm command wm-reload-config
}

function zebar-restart {
    Get-Process zebar -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep -Milliseconds 300
    Start-Process "C:\Program Files\glzr.io\Zebar\zebar.exe"
    Write-Host "Zebar restarted." -ForegroundColor Magenta
}

function nix-pull {
    wsl -d NixOS -u dyna -- git -C /etc/nixos pull --rebase
}

function tp {
    $candidates = @("$HOME\cswip", "$HOME\CLG", "$HOME\exploitationhomeworks")
    foreach ($base in $candidates) {
        if (Test-Path $base) {
            $latest = Get-ChildItem $base -Directory -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
            if ($latest) { Set-Location $latest.FullName; Write-Host $latest.FullName -ForegroundColor Cyan; return }
        }
    }
    Write-Host "No homework directory found." -ForegroundColor Yellow
}

function wm-keys {
    Write-Host @"

  GlazeWM (F24 = Super/CapsLock via PowerToys) — Colemak-DH
  ---------------------------------------------------------
  F24 + n/e/i/o (or Arrows)     Focus left/down/up/right
  F24 + Shift + n/e/i/o         Move window
  F24 + Ctrl + n/o              Prev / Next active workspace
  F24 + Tab                     Toggle recent workspace
  F24 + 1..0                    Focus workspace 1..10
  F24 + Shift + 1..0            Move window & follow
  F24 + Alt + 1..0              Move window silently
  F24 + R                       Resize mode (n/e/i/o, Shift=8%, Esc=exit)
  F24 + F / T / J               Fullscreen / Floating / Flip tiling split
  F24 + Space                   Cycle tiling <-> floating focus
  F24 + Q                       Close window
  F24 + Shift + P               Pause / Resume GlazeWM (games / VMs)
  F24 + Enter / B / Alt+E       Terminal (WSL) / Zen Browser / Explorer
  F24 + Shift + R / B           Reload GlazeWM / Restart Zebar

  Windows Terminal Splits
  ---------------------------------------------------------
  Alt + Shift + V / S           Split right / down
  Ctrl + Shift + n/e/i/o        Move pane focus
  Ctrl + Shift + Z / W / T      Zoom pane / Close pane / New tab

"@ -ForegroundColor Gray
}

Set-Alias -Name v -Value nvim -ErrorAction SilentlyContinue
function ll { Get-ChildItem -Force @args | Format-Table Mode, LastWriteTime, Length, Name -AutoSize }
function which($name) { (Get-Command $name -ErrorAction SilentlyContinue).Source }
