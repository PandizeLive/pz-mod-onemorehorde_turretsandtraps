[CmdletBinding()]
param(
    [ValidateSet('Menu', 'Info', 'Check', 'Install', 'Mirror', 'Publish', 'Capture', 'Stage')]
    [string]$Action = 'Menu',
    [switch]$ValidateOnly,
    [string]$UserDataRoot = (Join-Path $env:USERPROFILE 'Zomboid')
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$infoPath = Join-Path $projectRoot 'Contents/mods/OneMoreHorde_Traps/42.20/mod.info'
$version = ((Get-Content -LiteralPath $infoPath | Where-Object { $_ -like 'modversion=*' }) -replace '^modversion=', '').Trim()

function Invoke-ReleaseAction {
    param([string]$Selection, [bool]$CheckOnly)
    switch ($Selection) {
        'Info' {
            . (Join-Path $PSScriptRoot 'OMH-WorkshopCommon.ps1')
            $stage = Get-TTStagePath $UserDataRoot
            $itemId = Get-TTWorkshopId $projectRoot $stage
            @{ Project = 'OMH: Turrets & Traps'; Version = $version; Status = 'Development build'; Tag = "test/v$version"; Remote = (Get-Content (Join-Path $PSScriptRoot 'github-process.json') -Raw | ConvertFrom-Json).repository; PlanningBranch = 'dev'; WorkshopId = $itemId; Workshop = $stage; Visibility = 'Unlisted'; InitialUploadPending = (-not $itemId) } | ConvertTo-Json
        }
        'Check' { & (Join-Path $PSScriptRoot 'Install-Packages.ps1') -ValidateOnly }
        'Install' { & (Join-Path $PSScriptRoot 'Install-Packages.ps1') -ValidateOnly:$CheckOnly }
        'Capture' { & (Join-Path $PSScriptRoot 'Capture-Diagnostics.ps1') }
        'Mirror' { & (Join-Path $PSScriptRoot 'Mirror-Development.ps1') -ValidateOnly:$CheckOnly }
        'Stage' {
            $arguments = @('-NoLogo', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', (Join-Path $PSScriptRoot 'Stage-Workshop.ps1'), '-UserDataRoot', $UserDataRoot)
            if ($CheckOnly) { $arguments += '-ValidateOnly' }
            & "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" @arguments
            if ($LASTEXITCODE -ne 0) { throw 'Workshop staging failed.' }
        }
        'Publish' {
            $arguments = @('-NoLogo', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', (Join-Path $PSScriptRoot 'Publish-OMHWorkshop.ps1'), '-UserDataRoot', $UserDataRoot)
            if ($CheckOnly) { $arguments += '-PreflightOnly' }
            & "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" @arguments
            if ($LASTEXITCODE -ne 0) { throw 'Workshop update stopped. Review the message above.' }
        }
    }
}

try {
    if ($Action -ne 'Menu') {
        Invoke-ReleaseAction $Action ([bool]$ValidateOnly)
        exit 0
    }
    if ($ValidateOnly) { throw 'Choose -Action Install -ValidateOnly or -Action Check.' }
    while ($true) {
        Write-Host "`nOMH: Turrets & Traps v$version - Development build"
        Write-Host '1 Install locally'
        Write-Host '2 Mirror development to GitHub'
        Write-Host '3 Update unlisted Steam Workshop item (after first in-game upload)'
        Write-Host '4 Check local install readiness'
        Write-Host '5 Check Workshop update readiness (no upload)'
        Write-Host '6 Project-specific tools: Workshop staging / debug logs'
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
                '6' {
                    Write-Host '1 Stage/refresh files for the Zomboid Workshop uploader'
                    Write-Host '2 Check Workshop staging (no changes)'
                    Write-Host '3 Capture debug logs'
                    Write-Host '0 Back'
                    switch (Read-Host 'Select a tool') {
                        '1' { Invoke-ReleaseAction 'Stage' $false }
                        '2' { Invoke-ReleaseAction 'Stage' $true }
                        '3' { Invoke-ReleaseAction 'Capture' $false }
                    }
                }
                default { Write-Host 'Choose 0 through 6.' }
            }
        } catch { Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red }
    }
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
