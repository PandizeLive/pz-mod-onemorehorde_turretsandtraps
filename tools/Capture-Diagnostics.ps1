param([string]$ZomboidDirectory = (Join-Path $env:USERPROFILE 'Zomboid'))

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSHOME 'Modules/Microsoft.PowerShell.Utility/Microsoft.PowerShell.Utility.psd1') -Force
$projectRoot = Split-Path -Parent $PSScriptRoot
$captureDirectory = Join-Path $projectRoot ('diagnostics/captures/' + (Get-Date -Format 'yyyyMMdd-HHmmss-ffff'))
New-Item -ItemType Directory -Path $captureDirectory -Force | Out-Null
$consolePath = Join-Path $ZomboidDirectory 'console.txt'
Copy-Item -LiteralPath $consolePath -Destination (Join-Path $captureDirectory 'console.txt')
$lines = Get-Content -LiteralPath (Join-Path $captureDirectory 'console.txt')
$lines | Select-String -Pattern '\[OMHTT' | ForEach-Object { $_.Line } | Set-Content -LiteralPath (Join-Path $captureDirectory 'omhtt.log') -Encoding utf8
$lines | Select-String -Pattern 'ERROR|Exception|STACK TRACE|function:' -Context 2,8 | Out-String -Width 240 | Set-Content -LiteralPath (Join-Path $captureDirectory 'errors.log') -Encoding utf8
foreach ($id in @('OneMoreHorde_Traps', 'OneMoreHorde_Turrets', 'OneMoreHorde_TurretsAndTraps')) {
    $installedMarker = Join-Path $ZomboidDirectory "mods/$id/.omhtt-foundation-install.json"
    if (Test-Path -LiteralPath $installedMarker) {
        Copy-Item -LiteralPath $installedMarker -Destination (Join-Path $captureDirectory "$id-manifest.json")
    }
}
$hash = (Get-FileHash -LiteralPath (Join-Path $captureDirectory 'console.txt') -Algorithm SHA256).Hash
@{ capturedAt = (Get-Date).ToString('o'); source = $consolePath; sha256 = $hash } | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $captureDirectory 'capture.json') -Encoding utf8
Write-Output "Captured console, OMHTT trace, error context and installed package identity: $captureDirectory"
