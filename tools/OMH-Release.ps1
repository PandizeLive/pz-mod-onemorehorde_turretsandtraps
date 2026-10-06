[CmdletBinding()]
param(
    [ValidateSet('Menu', 'Info', 'Check', 'Install', 'Mirror', 'Publish', 'Capture')]
    [string]$Action = 'Menu',
    [switch]$ValidateOnly
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$infoPath = Join-Path $projectRoot 'Contents/mods/OneMoreHorde_Traps/42.20/mod.info'
$version = ((Get-Content -LiteralPath $infoPath | Where-Object { $_ -like 'modversion=*' }) -replace '^modversion=', '').Trim()

function Invoke-ReleaseAction {
    param([string]$Selection, [bool]$CheckOnly)
    switch ($Selection) {
        'Info' { @{ Project = 'OMH: Turrets & Traps'; Version = $version; Tag = "test/v$version"; Remote = 'Not configured'; Workshop = 'Not configured' } | ConvertTo-Json }
        'Check' { & (Join-Path $PSScriptRoot 'Install-Packages.ps1') -ValidateOnly }
        'Install' { & (Join-Path $PSScriptRoot 'Install-Packages.ps1') -ValidateOnly:$CheckOnly }
        'Capture' { & (Join-Path $PSScriptRoot 'Capture-Diagnostics.ps1') }
        'Mirror' { throw 'GitHub mirroring is unavailable: no configured remote or draft PR. Nothing was pushed.' }
        'Publish' { throw 'Workshop publishing is unavailable: no configured Workshop item or publisher. Nothing was uploaded.' }
    }
}

try {
    if ($Action -ne 'Menu') {
        Invoke-ReleaseAction $Action ([bool]$ValidateOnly)
        exit 0
    }
    if ($ValidateOnly) { throw 'Choose -Action Install -ValidateOnly or -Action Check.' }
    while ($true) {
        Write-Host "`nOMH: Turrets & Traps v$version"
        Write-Host '1 Install locally'
        Write-Host '2 Mirror to GitHub (not configured)'
        Write-Host '3 Publish mod to Steam Workshop (not configured)'
        Write-Host '4 Check local install readiness'
        Write-Host '5 Check Workshop upload readiness (not configured)'
        Write-Host '6 Project-specific tools: capture debug logs'
        Write-Host '0 Exit'
        $choice = Read-Host 'Select an action'
        if ($choice -eq '0') { exit 0 }
        try {
            switch ($choice) {
                '1' { Invoke-ReleaseAction 'Install' $false }
                '2' { Invoke-ReleaseAction 'Mirror' $false }
                '3' { Invoke-ReleaseAction 'Publish' $false }
                '4' { Invoke-ReleaseAction 'Check' $true }
                '5' { Invoke-ReleaseAction 'Publish' $true }
                '6' { Invoke-ReleaseAction 'Capture' $false }
                default { Write-Host 'Choose 0 through 6.' }
            }
        } catch { Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red }
    }
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
