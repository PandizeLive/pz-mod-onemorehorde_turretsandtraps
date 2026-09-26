param([string]$ModsDirectory = (Join-Path $env:USERPROFILE 'Zomboid/mods'), [switch]$ValidateOnly)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSHOME 'Modules/Microsoft.PowerShell.Utility/Microsoft.PowerShell.Utility.psd1') -Force
$projectRoot = Split-Path -Parent $PSScriptRoot
$packageId = 'OneMoreHorde_TurretsAndTraps'
$sourcePath = Join-Path $projectRoot "Contents/mods/$packageId"
$packageVersion = ((Get-Content -LiteralPath (Join-Path $sourcePath '42.20/mod.info') | Where-Object { $_ -like 'modversion=*' }) -replace '^modversion=', '').Trim()
$manifestPath = Join-Path $projectRoot ('diagnostics/v' + $packageVersion + '/manifest.json')
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
if ($manifest.version -ne $packageVersion) { throw 'Manifest version differs from packaged mod.info.' }
$branch = & git -c "safe.directory=$projectRoot" -C $projectRoot symbolic-ref --short HEAD
if ($LASTEXITCODE -ne 0 -or $branch -eq "main" -or $branch -eq "master") { throw "Use a non-main working branch for local test builds." }
$tag = "test/v$packageVersion"
$tagType = & git -c "safe.directory=$projectRoot" -C $projectRoot cat-file -t "refs/tags/$tag" 2>$null
if ($LASTEXITCODE -ne 0 -or $tagType -ne 'tag') { throw "Create the annotated local $tag rollback tag before installing." }
& git -c "safe.directory=$projectRoot" -C $projectRoot diff --quiet $tag -- Contents
if ($LASTEXITCODE -ne 0) { throw 'Packaged Contents differ from the local release tag.' }
$untracked = & git -c "safe.directory=$projectRoot" -C $projectRoot ls-files --others --exclude-standard -- Contents
if ($LASTEXITCODE -ne 0 -or $untracked) { throw 'Untracked package files are not covered by the release tag.' }
$destinationRoot = [IO.Path]::GetFullPath($ModsDirectory)
$destinationPath = [IO.Path]::GetFullPath((Join-Path $destinationRoot $packageId))
if (-not $destinationPath.StartsWith($destinationRoot.TrimEnd('\') + '\', [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Install destination escaped the selected mods directory.'
}
$markerPath = Join-Path $destinationPath '.omhtt-foundation-install.json'
$previousManifest = $null
foreach ($entry in $manifest.files.PSObject.Properties) {
    $sourceFile = Join-Path $sourcePath $entry.Name
    if ((Get-FileHash -LiteralPath $sourceFile -Algorithm SHA256).Hash.ToLowerInvariant() -ne $entry.Value) {
        throw "Source changed since validation: $($entry.Name). Run validate_foundation.py first."
    }
}
if (Test-Path -LiteralPath $destinationPath) {
    if (-not (Test-Path -LiteralPath $markerPath)) {
        throw "An unmanaged installation already exists at $destinationPath; left untouched."
    }
    $previousManifest = Get-Content -LiteralPath $markerPath -Raw | ConvertFrom-Json
}
if ($ValidateOnly) {
    Write-Output "Local readiness passed: v$packageVersion, $tag and validated source. No files installed."
    return
}
if ($previousManifest) {
    $backupPath = Join-Path $projectRoot ('diagnostics/p1c1/install-backups/' + (Get-Date -Format 'yyyyMMdd-HHmmss-ffff'))
    New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
    Copy-Item -LiteralPath $destinationPath -Destination $backupPath -Recurse
}
foreach ($entry in $manifest.files.PSObject.Properties) {
    $destinationFile = [IO.Path]::GetFullPath((Join-Path $destinationPath $entry.Name))
    if (-not $destinationFile.StartsWith($destinationPath + '\', [StringComparison]::OrdinalIgnoreCase)) {
        throw 'Package path escaped the installation.'
    }
    New-Item -ItemType Directory -Path (Split-Path -Parent $destinationFile) -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $sourcePath $entry.Name) -Destination $destinationFile -Force
    if ((Get-FileHash -LiteralPath $destinationFile -Algorithm SHA256).Hash.ToLowerInvariant() -ne $entry.Value) {
        throw "Installed file failed verification: $($entry.Name)"
    }
}
if ($previousManifest) {
    foreach ($entry in $previousManifest.files.PSObject.Properties) {
        if ($manifest.files.PSObject.Properties.Name -contains $entry.Name) { continue }
        $retiredFile = [IO.Path]::GetFullPath((Join-Path $destinationPath $entry.Name))
        if (-not $retiredFile.StartsWith($destinationPath + '\', [StringComparison]::OrdinalIgnoreCase)) {
            throw 'Retired package path escaped the installation.'
        }
        if ((Test-Path -LiteralPath $retiredFile) -and (Get-FileHash -LiteralPath $retiredFile -Algorithm SHA256).Hash.ToLowerInvariant() -eq $entry.Value) {
            Remove-Item -LiteralPath $retiredFile
        }
    }
}
$encoding = New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllText($markerPath, ($manifest | ConvertTo-Json -Depth 8), $encoding)
Write-Output "Installed and verified $($manifest.version) at $destinationPath"
Write-Output 'Restart PZ and enable OMH: Turrets & Traps. Confirm the loaded version before gameplay testing.'
