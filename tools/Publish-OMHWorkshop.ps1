[CmdletBinding()]
param(
    [switch]$PreflightOnly,
    [switch]$ResetCredentials,
    [string]$UserDataRoot = (Join-Path $env:USERPROFILE 'Zomboid')
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'OMH-WorkshopCommon.ps1')
. (Join-Path $PSScriptRoot 'OMH-SteamHelpers.ps1')
$repoRoot = Split-Path -Parent $PSScriptRoot
$publisherRoot = Join-Path $env:LOCALAPPDATA 'OMH\TurretsAndTrapsPublisher'
$credentialPath = Join-Path $publisherRoot 'steam-credential.xml'
$changeLogPath = Join-Path $repoRoot 'WORKSHOP_CHANGELOG.txt'
$steamCmdPath = Find-TTSharedPath $repoRoot '.tools\steamcmd\steamcmd.exe'
$uploadConfirmed = $false

function New-TTWorkshopVdf {
    param([string]$ContentFolder, [string]$ItemId, [string]$ChangeNote)
    if ($ItemId -notmatch '^[1-9]\d{5,19}$' -or $ItemId -in @('3777891317', '3803035618')) { throw 'An existing T&T Workshop ID is required. This updater cannot create an item.' }
    $fields = [ordered]@{ appid = '108600'; publishedfileid = $ItemId; contentfolder = $ContentFolder; changenote = $ChangeNote; visibility = '3' }
    $lines = @('"workshopitem"', '{')
    foreach ($key in $fields.Keys) { $lines += '    "' + $key + '" "' + (ConvertTo-VdfValue $fields[$key]) + '"' }
    return ($lines + '}') -join "`r`n"
}

try {
    $release = Get-TTRelease $repoRoot
    $stage = Get-TTStagePath $UserDataRoot
    $workshopId = Get-TTWorkshopId $repoRoot $stage
    if (-not $workshopId) { throw "Initial in-game upload is pending. Upload $stage through Zomboid first; the game writes its ID to workshop.txt. Nothing was uploaded." }
    if (-not $steamCmdPath) { throw 'SteamCMD is missing from the shared .tools/steamcmd folder.' }
    $changeLog = Get-WorkshopChangeNote $release.Version
    $manifest = New-TTWorkshopVdf (Join-Path $repoRoot 'Contents') $workshopId $changeLog.Steam
    Write-Host "OMH: Turrets & Traps v$($release.Version) - update item $workshopId - UNLISTED"
    Write-Host "https://steamcommunity.com/sharedfiles/filedetails/?id=$workshopId"
    Write-Host 'Content and change notes will update; the page title, description, tags and cover are preserved.'
    if ($PreflightOnly) {
        Write-Host $manifest
        Write-Host "Preflight passed: $($release.Files.Count) tagged content files. No network calls, files, credentials or Steam processes changed."
        Write-Host 'Live upload additionally requires committed release inputs and Project Zomboid closed.'
        exit 0
    }
    $criticalPaths = @('Source', 'Contents', 'tools', 'OMH.cmd', 'OMH_TurretsAndTraps.cmd', 'workshop.txt', 'preview.png', 'WORKSHOP_CHANGELOG.txt')
    if (Invoke-TTGit $repoRoot (@('status', '--porcelain', '--untracked-files=all', '--') + $criticalPaths)) { throw 'Commit release inputs and tooling before publishing.' }
    Assert-ProjectZomboidClosed
    Write-Host $changeLog.Source
    if ((Read-Host "Type PUBLISH to upload v$($release.Version) to unlisted T&T item $workshopId").Trim() -ine 'PUBLISH') { throw 'Upload cancelled.' }
    $snapshot = New-TTContentSnapshot $release 'upload'
    [IO.File]::WriteAllText((Join-Path $snapshot 'WORKSHOP_CHANGELOG.txt'), $changeLog.Source, [Text.UTF8Encoding]::new($false))
    $vdfPath = Join-Path $snapshot 'upload.vdf'
    $logPath = Join-Path $snapshot 'steamcmd.log'
    [IO.File]::WriteAllText($vdfPath, (New-TTWorkshopVdf (Join-Path $snapshot 'Contents') $workshopId $changeLog.Steam), [Text.UTF8Encoding]::new($false))
    $record = [ordered]@{
        status = 'pending'; itemId = $workshopId; version = $release.Version; visibility = 'unlisted'
        tag = $release.Tag; sourceCommit = $release.Commit; toolingCommit = $release.Head
        files = $release.Files; changelogSha256 = (Get-FileHash -LiteralPath (Join-Path $snapshot 'WORKSHOP_CHANGELOG.txt') -Algorithm SHA256).Hash
        startedUtc = [DateTime]::UtcNow.ToString('o'); log = $logPath
    }
    $receipt = Join-Path $snapshot 'upload-result.json'
    Write-TTJson $receipt $record
    $credential = Get-PublisherCredential
    $steamPath = Get-SteamPath
    $guardCode = Read-GuardCode
    $steamWasRunning = Stop-SteamClient $steamPath
    try {
        if ((Get-TTWorkshopId $repoRoot $stage) -ne $workshopId) { throw 'Workshop target changed during confirmation.' }
        Assert-TTHashes (Join-Path $snapshot 'Contents') $release.Files
        Invoke-SteamCmdUpload $credential $guardCode $logPath
        $uploadConfirmed = $true
        $record.status = 'confirmed'
        $record.confirmedUtc = [DateTime]::UtcNow.ToString('o')
        Write-TTJson $receipt $record
        $metadataPath = Join-Path $repoRoot 'workshop.txt'
        $metadata = Read-TTWorkshopMetadata $metadataPath
        if ($metadata.Id -and $metadata.Id -ne $workshopId) { throw 'Project Workshop identity changed during the upload. Preserve the receipt and resolve the local identity.' }
        if (-not $metadata.Id) {
            [IO.File]::WriteAllText($metadataPath, ([regex]::Replace($metadata.Text, '(?m)^id=\r?$', "id=$workshopId")), [Text.UTF8Encoding]::new($false))
            Write-Host 'Recorded the game-created ID in project workshop.txt. Commit this identity before the next update.'
        }
        $releasePath = Join-Path $repoRoot 'docs\RELEASE.md'
        $entry = "`r`n## Confirmed unlisted development upload - v$($release.Version)`r`n`r`nSteamCMD confirmed item $workshopId at $($record.confirmedUtc). Source: $($release.Tag) / $($release.Commit). Receipt with content hashes and log: $receipt. Published changelog snapshot: $snapshot\WORKSHOP_CHANGELOG.txt. This is the content baseline for this item only; retain the cumulative draft until the next change, preserving any newer unpublished notes. No official release promotion.`r`n"
        [IO.File]::AppendAllText($releasePath, $entry, [Text.UTF8Encoding]::new($false))
        Write-Host "Upload confirmed: https://steamcommunity.com/sharedfiles/filedetails/?id=$workshopId"
        Write-Host "Evidence: $receipt"
    } finally {
        if ($steamWasRunning) { Start-Process -FilePath $steamPath -WindowStyle Hidden | Out-Null }
    }
} catch {
    if ($uploadConfirmed) { Write-Host "Steam already confirmed the upload. Local bookkeeping failed; inspect $receipt before retrying." -ForegroundColor Yellow }
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
