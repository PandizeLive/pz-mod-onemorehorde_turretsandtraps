[CmdletBinding()]
param([switch]$ValidateOnly)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$config = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'github-process.json') -Raw | ConvertFrom-Json
$gitRoot = $projectRoot.Replace('\', '/')
$gitAuth = @()

function Invoke-ProjectGit {
    param([string[]]$Arguments)
    $output = & git -c "safe.directory=$gitRoot" -C $projectRoot @gitAuth @Arguments
    if ($LASTEXITCODE -ne 0) { throw "Git failed: $($Arguments[0]). Resolve the reported problem before retrying." }
    return $output
}

function Find-SharedPath {
    param([string]$RelativePath)
    $directory = $projectRoot
    while ($directory) {
        $candidate = Join-Path $directory $RelativePath
        if (Test-Path -LiteralPath $candidate) { return $candidate }
        $directory = Split-Path -Parent $directory
    }
}

function Invoke-GitHub {
    param([string[]]$Arguments)
    $output = & $ghPath @Arguments
    if ($LASTEXITCODE -ne 0) { throw "GitHub CLI failed: $($Arguments[0])." }
    return $output
}

$branch = Invoke-ProjectGit @('symbolic-ref', '--short', 'HEAD')
if ($branch -in @($config.releaseBranch, 'master')) { throw 'Official release branches cannot be mirrored by this command. Use dev or a development/planning branch.' }
if (Invoke-ProjectGit @('status', '--porcelain', '--untracked-files=all')) { throw 'Commit intended changes before mirroring. Keep local caches and credentials ignored.' }
foreach ($arguments in @(@('remote', 'get-url', '--all', 'origin'), @('remote', 'get-url', '--push', '--all', 'origin'))) {
    $urls = @(Invoke-ProjectGit $arguments)
    if ($urls.Count -ne 1 -or $urls[0] -ne $config.remote) { throw 'Origin fetch and push URLs must match the configured private repository.' }
}
$head = Invoke-ProjectGit @('rev-parse', 'HEAD')
$version = ((Get-Content -LiteralPath (Join-Path $projectRoot 'Source/42.20/mod.info') | Where-Object { $_ -like 'modversion=*' }) -replace '^modversion=', '').Trim()
$tag = "test/v$version"
$pushTag = $false
& git -c "safe.directory=$gitRoot" -C $projectRoot show-ref --verify --quiet "refs/tags/$tag"
if ($LASTEXITCODE -eq 0) {
    $type = Invoke-ProjectGit @('cat-file', '-t', "refs/tags/$tag")
    & git -c "safe.directory=$gitRoot" -C $projectRoot merge-base --is-ancestor $tag HEAD
    $ancestor = $LASTEXITCODE -eq 0
    & git -c "safe.directory=$gitRoot" -C $projectRoot diff --quiet $tag HEAD -- Source Contents
    $unchanged = $LASTEXITCODE -eq 0
    $pushTag = $type -eq 'tag' -and $ancestor -and $unchanged
}
if ($ValidateOnly) {
    Write-Output "Local mirror checks passed: $branch at $head; include current test tag: $pushTag. No network calls or remote changes."
    return
}
$ghPath = Find-SharedPath '.tools/gh.exe'
if (-not $ghPath) { $ghPath = (Get-Command gh -ErrorAction Stop).Source }
$ghConfig = Find-SharedPath '.gh-codex'
if ($ghConfig) { $env:GH_CONFIG_DIR = $ghConfig }
$gitAuth = @('-c', 'credential.helper=', '-c', ('credential.helper=!"' + $ghPath.Replace('\', '/') + '" auth git-credential'))
$repository = Invoke-GitHub @('repo', 'view', $config.repository, '--json', 'nameWithOwner,isPrivate,defaultBranchRef') | ConvertFrom-Json
if (-not $repository.isPrivate -or $repository.nameWithOwner -ne $config.repository -or $repository.defaultBranchRef.name -ne $config.developmentBranch) { throw 'Expected the configured private repository with dev as its default branch.' }
Invoke-ProjectGit @('fetch', 'origin', '--prune') | Out-Host
Invoke-ProjectGit @('merge-base', '--is-ancestor', "origin/$($config.developmentBranch)", 'HEAD') | Out-Null
$refspecs = @("HEAD:refs/heads/$branch")
if ($pushTag) {
    $remoteTag = @(Invoke-ProjectGit @('ls-remote', 'origin', "refs/tags/$tag"))
    $localTag = Invoke-ProjectGit @('rev-parse', "refs/tags/$tag")
    if ($remoteTag.Count -gt 0 -and ($remoteTag[0] -split '\s+')[0] -ne $localTag) { throw 'Remote test tag differs. Never overwrite a tag.' }
    $refspecs += "refs/tags/${tag}:refs/tags/$tag"
}
Invoke-ProjectGit (@('push', '--atomic', '--set-upstream', 'origin') + $refspecs) | Out-Host
$remoteHead = @(Invoke-ProjectGit @('ls-remote', '--heads', 'origin', "refs/heads/$branch"))
if ($remoteHead.Count -ne 1 -or ($remoteHead[0] -split '\s+')[0] -ne $head) { throw 'Could not verify the pushed development commit.' }
if ($branch -ne $config.developmentBranch) {
    $result = Invoke-GitHub @('pr', 'list', '--repo', $config.repository, '--head', $branch, '--base', $config.developmentBranch, '--state', 'open', '--json', 'url') | ConvertFrom-Json
    $prs = @($result | Where-Object { $null -ne $_ })
    if ($prs.Count -eq 0) {
        $bodyPath = Join-Path $projectRoot '.local/development-pr.md'
        New-Item -ItemType Directory -Path (Split-Path -Parent $bodyPath) -Force | Out-Null
        $planningUrl = "https://github.com/$($config.repository)/blob/$branch/docs/PLANNING.md"
        $statusUrl = "https://github.com/$($config.repository)/blob/$branch/docs/CURRENT_STATUS.md"
        $body = "Development checkpoint for $branch, targeting dev.`n`n## Planning`n`n[Planning and approvals]($planningUrl) | [Current status]($statusUrl)`n`nReview the changed files and recorded decisions/test evidence before merging. This is not an official release or a Workshop upload.`n"
        [IO.File]::WriteAllText($bodyPath, $body, (New-Object Text.UTF8Encoding($false)))
        Invoke-GitHub @('pr', 'create', '--repo', $config.repository, '--base', $config.developmentBranch, '--head', $branch, '--draft', '--title', "Development: $branch", '--body-file', $bodyPath) | Out-Host
    } else { $prs | ForEach-Object { Write-Output $_.url } }
}
Write-Output "Verified development mirror: $head. No official release or Workshop upload was made."
