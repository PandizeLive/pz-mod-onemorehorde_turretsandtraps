param([string]$ModsDirectory = (Join-Path $env:USERPROFILE 'Zomboid/mods'), [switch]$ValidateOnly)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSHOME 'Modules/Microsoft.PowerShell.Utility/Microsoft.PowerShell.Utility.psd1') -Force
$projectRoot = Split-Path -Parent $PSScriptRoot
$gitRoot = $projectRoot.Replace('\', '/')
$packageIds = @('OneMoreHorde_Traps', 'OneMoreHorde_Turrets')
$legacyId = 'OneMoreHorde_TurretsAndTraps'
$markerName = '.omhtt-foundation-install.json'
$encoding = New-Object System.Text.UTF8Encoding($false)

function Get-ChildPath {
    param([string]$Root, [string]$Relative)
    $resolvedRoot = [IO.Path]::GetFullPath($Root).TrimEnd('\')
    $resolved = [IO.Path]::GetFullPath((Join-Path $resolvedRoot $Relative))
    if (-not $resolved.StartsWith($resolvedRoot + '\', [StringComparison]::OrdinalIgnoreCase)) {
        throw "Path escaped its managed root: $Relative"
    }
    return $resolved
}

function Assert-Hashes {
    param([string]$Root, $Files)
    foreach ($entry in $Files.PSObject.Properties) {
        $path = Get-ChildPath $Root $entry.Name
        if (-not (Test-Path -LiteralPath $path -PathType Leaf) -or (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant() -ne $entry.Value) {
            throw "File differs from its managed manifest: $path"
        }
    }
}

$info = Join-Path $projectRoot 'Contents/mods/OneMoreHorde_Traps/42.20/mod.info'
$version = ((Get-Content -LiteralPath $info | Where-Object { $_ -like 'modversion=*' }) -replace '^modversion=', '').Trim()
$manifest = Get-Content -LiteralPath (Join-Path $projectRoot "diagnostics/v$version/manifest.json") -Raw | ConvertFrom-Json
if ($manifest.version -ne $version) { throw 'Manifest version differs from packaged version.' }
if (@($manifest.packages.PSObject.Properties).Count -ne 2) { throw 'Expected two independent packages.' }
$branch = & git -c "safe.directory=$gitRoot" -C $projectRoot symbolic-ref --short HEAD
if ($LASTEXITCODE -ne 0 -or $branch -in @('main', 'master')) { throw 'Use a non-main working branch.' }
$tag = "test/v$version"
$tagType = & git -c "safe.directory=$gitRoot" -C $projectRoot cat-file -t "refs/tags/$tag" 2>$null
if ($LASTEXITCODE -ne 0 -or $tagType -ne 'tag') { throw "Create annotated rollback tag $tag first." }
& git -c "safe.directory=$gitRoot" -C $projectRoot diff --quiet $tag -- Contents Source
if ($LASTEXITCODE -ne 0) { throw 'Source or Contents differ from the release tag.' }
$untracked = & git -c "safe.directory=$gitRoot" -C $projectRoot ls-files --others --exclude-standard -- Contents Source
if ($LASTEXITCODE -ne 0 -or $untracked) { throw 'Untracked source/package files are not covered by the release tag.' }
Assert-Hashes (Join-Path $projectRoot 'Source') $manifest.sourceFiles
$destinationRoot = [IO.Path]::GetFullPath($ModsDirectory)
$previous = @{}
foreach ($id in $packageIds) {
    $files = $manifest.packages.$id
    if (-not $files) { throw "Missing package manifest: $id" }
    $source = Get-ChildPath (Join-Path $projectRoot 'Contents/mods') $id
    Assert-Hashes $source $files
    if (@(Get-ChildItem -LiteralPath $source -File -Recurse -Force).Count -ne @($files.PSObject.Properties).Count) { throw "Unmanifested package files: $id" }
    $componentVersion = ((Get-Content -LiteralPath (Join-Path $source '42.20/mod.info') | Where-Object { $_ -like 'modversion=*' }) -replace '^modversion=', '').Trim()
    if ($componentVersion -ne $version) { throw 'Component versions differ.' }
}
foreach ($id in @($packageIds) + @($legacyId)) {
    $destination = Get-ChildPath $destinationRoot $id
    if (-not (Test-Path -LiteralPath $destination)) { continue }
    if ((Get-Item -LiteralPath $destination).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Refusing managed junction: $destination" }
    $marker = Join-Path $destination $markerName
    if (-not (Test-Path -LiteralPath $marker -PathType Leaf)) { throw "Unmanaged installation left untouched: $destination" }
    $previous[$id] = Get-Content -LiteralPath $marker -Raw | ConvertFrom-Json
    Assert-Hashes $destination $previous[$id].files
}
if ($ValidateOnly) {
    Write-Output "Local readiness passed: v$version, two independent packages, $tag. No files installed."
    return
}
$transaction = Get-Date -Format 'yyyyMMdd-HHmmss-ffff'
$backupRoot = Get-ChildPath $projectRoot "diagnostics/p1c1/install-backups/$transaction"
$stageRoot = Get-ChildPath $projectRoot "diagnostics/p1c1/install-stage/$transaction"
New-Item -ItemType Directory -Path $backupRoot, $stageRoot, $destinationRoot -Force | Out-Null
$moved = @()
$installed = @()
try {
    foreach ($id in $packageIds) {
        $stage = Get-ChildPath $stageRoot $id
        $destination = Get-ChildPath $destinationRoot $id
        if ($previous.ContainsKey($id)) {
            Copy-Item -LiteralPath $destination -Destination $stage -Recurse
            foreach ($entry in $previous[$id].files.PSObject.Properties) {
                if ($manifest.packages.$id.PSObject.Properties.Name -notcontains $entry.Name) {
                    Remove-Item -LiteralPath (Get-ChildPath $stage $entry.Name) -Force
                }
            }
        } else {
            New-Item -ItemType Directory -Path $stage -Force | Out-Null
        }
        foreach ($entry in $manifest.packages.$id.PSObject.Properties) {
            $target = Get-ChildPath $stage $entry.Name
            New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force | Out-Null
            Copy-Item -LiteralPath (Get-ChildPath (Join-Path $projectRoot "Contents/mods/$id") $entry.Name) -Destination $target -Force
        }
        Assert-Hashes $stage $manifest.packages.$id
        $installedManifest = @{ version = $version; packageId = $id; files = $manifest.packages.$id }
        [IO.File]::WriteAllText((Join-Path $stage $markerName), ($installedManifest | ConvertTo-Json -Depth 8), $encoding)
    }
    foreach ($id in @($packageIds) + @($legacyId)) {
        if (-not $previous.ContainsKey($id)) { continue }
        $destination = Get-ChildPath $destinationRoot $id
        $backup = Get-ChildPath $backupRoot $id
        Move-Item -LiteralPath $destination -Destination $backup
        $moved += $id
    }
    foreach ($id in $packageIds) {
        $stage = Get-ChildPath $stageRoot $id
        $destination = Get-ChildPath $destinationRoot $id
        Move-Item -LiteralPath $stage -Destination $destination
        $installed += $id
        Assert-Hashes $destination $manifest.packages.$id
    }
} catch {
    foreach ($id in $installed) {
        $destination = Get-ChildPath $destinationRoot $id
        Remove-Item -LiteralPath $destination -Recurse -Force
    }
    foreach ($id in $moved) {
        $backup = Get-ChildPath $backupRoot $id
        $destination = Get-ChildPath $destinationRoot $id
        Move-Item -LiteralPath $backup -Destination $destination
    }
    throw
}
$record = @{ version = $version; tag = $tag; installedAt = (Get-Date).ToString('o'); destination = $destinationRoot; backup = $backupRoot; packages = $packageIds; retiredCombined = $previous.ContainsKey($legacyId) }
[IO.File]::WriteAllText((Join-Path $projectRoot "diagnostics/v$version/install.json"), ($record | ConvertTo-Json -Depth 8), $encoding)
Write-Output "Installed and verified v${version}: OMH: Traps and OMH: Turrets. Backup: $backupRoot"
Write-Output 'Use a fresh test world. Enable either entry or both; neither requires the other. Player testing remains deferred.'
