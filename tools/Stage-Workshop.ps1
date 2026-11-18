[CmdletBinding()]
param([switch]$ValidateOnly, [string]$UserDataRoot = (Join-Path $env:USERPROFILE 'Zomboid'))

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'OMH-WorkshopCommon.ps1')
$root = Split-Path -Parent $PSScriptRoot
$release = Get-TTRelease $root
$stage = Get-TTStagePath $UserDataRoot
$id = Get-TTWorkshopId $root $stage
$metadataRoot = $root
if (Test-Path -LiteralPath $stage) {
    $marker = Get-Content -LiteralPath (Join-Path $stage '.omhtt-workshop-stage.json') -Raw | ConvertFrom-Json
    Assert-TTHashes (Join-Path $stage 'Contents') $marker.files
    $metadataRoot = $stage
}
$metadata = Read-TTWorkshopMetadata (Join-Path $metadataRoot 'workshop.txt')
Assert-TTPreview (Join-Path $metadataRoot 'preview.png')
if ($ValidateOnly) {
    Write-Output "Workshop staging ready: v$($release.Version), $($release.Files.Count) files, $stage. No files changed."
    return
}
$snapshot = New-TTContentSnapshot $release 'stage'
foreach ($name in @('workshop.txt', 'preview.png')) { Copy-Item -LiteralPath (Join-Path $metadataRoot $name) -Destination (Join-Path $snapshot $name) }
if ($id -and -not $metadata.Id) {
    [IO.File]::WriteAllText((Join-Path $snapshot 'workshop.txt'), ([regex]::Replace($metadata.Text, '(?m)^id=\r?$', "id=$id")), [Text.UTF8Encoding]::new($false))
}
Write-TTJson (Join-Path $snapshot '.omhtt-workshop-stage.json') @{
    product = 'OMH: Turrets & Traps'; version = $release.Version; tag = $release.Tag
    commit = $release.Commit; files = $release.Files; stagedUtc = [DateTime]::UtcNow.ToString('o')
}
$backup = $snapshot + '-previous'
Assert-TTPlainPath $stage
Assert-TTPlainPath $backup
if ((Test-Path -LiteralPath $stage) -and (Get-Content -LiteralPath (Join-Path $stage 'workshop.txt') -Raw -Encoding UTF8) -cne $metadata.Text) {
    throw 'The game changed Workshop metadata while staging. Existing files were preserved; retry after leaving the uploader.'
}
if ([IO.Path]::GetFullPath($backup).StartsWith([IO.Path]::GetFullPath((Join-Path $root 'diagnostics\workshop')) + '\', [StringComparison]::OrdinalIgnoreCase) -eq $false) { throw 'Backup escaped the project diagnostics folder.' }
New-Item -ItemType Directory -Path (Split-Path -Parent $stage) -Force | Out-Null
$moved = $false
try {
    if (Test-Path -LiteralPath $stage) {
        Move-Item -LiteralPath $stage -Destination $backup
        $moved = $true
    }
    Copy-Item -LiteralPath $snapshot -Destination $stage -Recurse
    Assert-TTHashes (Join-Path $stage 'Contents') $release.Files
} catch {
    if (Test-Path -LiteralPath $stage) { Move-Item -LiteralPath $stage -Destination ($snapshot + '-failed') }
    if ($moved) { Move-Item -LiteralPath $backup -Destination $stage }
    throw
}
Write-Output "Staged and verified v$($release.Version): $stage"
if ($id) { Write-Output "Preserved Workshop item $id and existing page metadata/preview." }
else { Write-Output 'In Zomboid choose Workshop > Create/Update Items > OneMoreHorde_TurretsAndTraps. Visibility is Unlisted. The game will write the new ID into workshop.txt.' }
