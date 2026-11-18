Import-Module (Join-Path $PSHOME 'Modules/Microsoft.PowerShell.Utility/Microsoft.PowerShell.Utility.psd1') -Force
Import-Module (Join-Path $PSHOME 'Modules/Microsoft.PowerShell.Security/Microsoft.PowerShell.Security.psd1') -Force

function Find-TTSharedPath {
    param([string]$Root, [string]$RelativePath)
    $folder = [IO.Path]::GetFullPath($Root)
    while ($folder) {
        $candidate = Join-Path $folder $RelativePath
        if (Test-Path -LiteralPath $candidate -PathType Leaf) { return $candidate }
        $folder = Split-Path -Parent $folder
    }
    return $null
}

function Invoke-TTGit {
    param([string]$Root, [string[]]$Arguments)
    $git = Get-Command git.exe -ErrorAction SilentlyContinue
    $gitPath = if ($git) { $git.Source } else { Join-Path $env:ProgramFiles 'Git\cmd\git.exe' }
    $result = & $gitPath -c "safe.directory=$($Root.Replace('\', '/'))" -C $Root @Arguments
    if ($LASTEXITCODE -ne 0) { throw "Git failed: $($Arguments -join ' ')" }
    return $result
}

function Assert-TTPlainPath {
    param([string]$Path)
    $candidate = [IO.Path]::GetFullPath($Path)
    while ($candidate) {
        if ((Test-Path -LiteralPath $candidate) -and ((Get-Item -LiteralPath $candidate -Force).Attributes -band [IO.FileAttributes]::ReparsePoint)) {
            throw "Linked path is not supported: $candidate"
        }
        $candidate = Split-Path -Parent $candidate
    }
}

function Get-TTFileHashes {
    param([string]$Root)
    Assert-TTPlainPath $Root
    $files = [ordered]@{}
    foreach ($item in Get-ChildItem -LiteralPath $Root -Recurse -Force) {
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Linked content: $($item.FullName)" }
        if (-not $item.PSIsContainer) {
            $relative = $item.FullName.Substring($Root.TrimEnd('\').Length + 1).Replace('\', '/')
            $files[$relative] = (Get-FileHash -LiteralPath $item.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
        }
    }
    return $files
}

function Assert-TTHashes {
    param([string]$Root, $Expected)
    $actual = Get-TTFileHashes $Root
    $entries = if ($Expected -is [Collections.IDictionary]) { @($Expected.Keys) } else { @($Expected.PSObject.Properties.Name) }
    if ($actual.Count -ne $entries.Count) { throw "Unexpected file count in $Root" }
    foreach ($name in $entries) {
        if ($actual[$name] -ne $Expected.$name) { throw "Content hash mismatch: $Root/$name" }
    }
}

function Get-TTRelease {
    param([string]$Root)
    $rootPath = [IO.Path]::GetFullPath($Root)
    $ids = @('OneMoreHorde_Traps', 'OneMoreHorde_Turrets')
    $contents = Join-Path $rootPath 'Contents'
    $top = @(Get-ChildItem -LiteralPath $contents -Force)
    $packages = @(Get-ChildItem -LiteralPath (Join-Path $contents 'mods') -Force)
    if ($top.Count -ne 1 -or $top[0].Name -ne 'mods' -or $packages.Count -ne 2) { throw 'Expected only the two T&T packages under Contents/mods.' }
    $versions = @()
    foreach ($package in $packages) {
        if (-not $package.PSIsContainer -or $package.Name -notin $ids) { throw "Unexpected package: $($package.Name)" }
        $info = Get-Content -LiteralPath (Join-Path $package.FullName '42.20/mod.info') -Raw
        $idMatch = [regex]::Matches($info, '(?m)^id=([^\r\n]+)\r?$')
        $versionMatch = [regex]::Matches($info, '(?m)^modversion=(\d+(?:\.\d+){2,3})\r?$')
        if ($idMatch.Count -ne 1 -or $idMatch[0].Groups[1].Value -ne $package.Name -or $versionMatch.Count -ne 1) { throw "Invalid package identity/version: $($package.Name)" }
        $versions += $versionMatch[0].Groups[1].Value
    }
    $versions = @($versions | Select-Object -Unique)
    if ($versions.Count -ne 1) { throw 'T&T package versions differ.' }
    $branch = [string](Invoke-TTGit $rootPath @('branch', '--show-current'))
    if ([string]::IsNullOrWhiteSpace($branch) -or $branch -in @('main', 'master')) { throw 'Use a non-main working branch.' }
    $tag = "test/v$($versions[0])"
    if ((Invoke-TTGit $rootPath @('cat-file', '-t', "refs/tags/$tag")) -ne 'tag') { throw "Annotated rollback tag required: $tag" }
    Invoke-TTGit $rootPath @('merge-base', '--is-ancestor', $tag, 'HEAD') | Out-Null
    Invoke-TTGit $rootPath @('diff', '--exit-code', $tag, '--', 'Source', 'Contents') | Out-Null
    if (Invoke-TTGit $rootPath @('ls-files', '--others', '--', 'Source', 'Contents')) { throw 'Untracked or ignored Source/Contents files are not covered by the tag.' }
    $hashes = Get-TTFileHashes $contents
    return [pscustomobject]@{
        Root = $rootPath; Version = $versions[0]; Tag = $tag; Branch = $branch; Files = $hashes
        Commit = [string](Invoke-TTGit $rootPath @('rev-parse', "$tag^{commit}"))
        Head = [string](Invoke-TTGit $rootPath @('rev-parse', 'HEAD'))
    }
}

function Get-TTStagePath {
    param([string]$UserDataRoot)
    $path = [IO.Path]::GetFullPath((Join-Path $UserDataRoot 'Workshop\OneMoreHorde_TurretsAndTraps'))
    Assert-TTPlainPath $path
    return $path
}

function Read-TTWorkshopMetadata {
    param([string]$Path)
    $text = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    $ids = [regex]::Matches($text, '(?m)^id=([^\r\n]*)\r?$')
    $titles = [regex]::Matches($text, '(?m)^title=([^\r\n]*)\r?$')
    if ($ids.Count -ne 1 -or $titles.Count -ne 1 -or $titles[0].Groups[1].Value -notlike 'OMH: Turrets & Traps*') { throw "Invalid T&T metadata: $Path" }
    $id = $ids[0].Groups[1].Value.Trim()
    $number = [UInt64]0
    if ($id -and (-not [UInt64]::TryParse($id, [ref]$number) -or $number -eq 0 -or $id -notmatch '^[1-9]\d{5,19}$')) { throw "Invalid Workshop ID in $Path" }
    if ($id -in @('3777891317', '3803035618')) { throw 'Refusing a sibling Workshop item.' }
    return [pscustomobject]@{ Id = $id; Text = $text; Path = $Path }
}

function Get-TTWorkshopId {
    param([string]$Root, [string]$Stage)
    $source = Read-TTWorkshopMetadata (Join-Path $Root 'workshop.txt')
    $staged = $null
    if (Test-Path -LiteralPath $Stage) {
        $marker = Get-Content -LiteralPath (Join-Path $Stage '.omhtt-workshop-stage.json') -Raw | ConvertFrom-Json
        if ($marker.product -ne 'OMH: Turrets & Traps') { throw 'Workshop folder is not a managed T&T stage.' }
        $staged = Read-TTWorkshopMetadata (Join-Path $Stage 'workshop.txt')
    }
    if ($source.Id -and $staged -and $staged.Id -and $source.Id -ne $staged.Id) { throw 'Source and staged Workshop IDs differ. Resolve the target before uploading.' }
    if ($source.Id) { return $source.Id }
    if ($staged -and $staged.Id) { return $staged.Id }
    return ''
}

function Assert-TTPreview {
    param([string]$Path)
    if ((Get-Item -LiteralPath $Path).Length -gt 1024000) { throw 'Preview PNG exceeds the native uploader size limit.' }
    $bytes = [IO.File]::ReadAllBytes($Path)
    if ($bytes.Length -lt 24 -or [BitConverter]::ToString($bytes[0..7]) -ne '89-50-4E-47-0D-0A-1A-0A') { throw 'Native upload requires a PNG preview.' }
    $width = ([int]$bytes[16] -shl 24) -bor ([int]$bytes[17] -shl 16) -bor ([int]$bytes[18] -shl 8) -bor [int]$bytes[19]
    $height = ([int]$bytes[20] -shl 24) -bor ([int]$bytes[21] -shl 16) -bor ([int]$bytes[22] -shl 8) -bor [int]$bytes[23]
    if ($width -ne $height -or $width -notin @(256, 512)) { throw 'Native preview must be 256x256 or 512x512.' }
}

function New-TTContentSnapshot {
    param($Release, [string]$Purpose)
    $parent = Join-Path $Release.Root 'diagnostics\workshop'
    Assert-TTPlainPath $parent
    $path = Join-Path $parent ("$Purpose-v$($Release.Version)-" + [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss-ffff') + '-' + [Guid]::NewGuid().ToString('N').Substring(0, 8))
    New-Item -ItemType Directory -Path $path -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $Release.Root 'Contents') -Destination (Join-Path $path 'Contents') -Recurse
    Assert-TTHashes (Join-Path $path 'Contents') $Release.Files
    return $path
}

function Write-TTJson {
    param([string]$Path, $Value)
    [IO.File]::WriteAllText($Path, ($Value | ConvertTo-Json -Depth 8), [Text.UTF8Encoding]::new($false))
}
