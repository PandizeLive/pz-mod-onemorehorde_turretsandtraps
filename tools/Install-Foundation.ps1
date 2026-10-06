param([string]$ModsDirectory = (Join-Path $env:USERPROFILE 'Zomboid/mods'), [switch]$ValidateOnly)
& (Join-Path $PSScriptRoot 'Install-Packages.ps1') @PSBoundParameters