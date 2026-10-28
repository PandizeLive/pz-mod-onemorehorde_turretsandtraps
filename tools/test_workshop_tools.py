import hashlib
import json
import os
import shutil
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SHELL = Path(os.environ['SystemRoot']) / 'System32/WindowsPowerShell/v1.0/powershell.exe'
IDS = ['OneMoreHorde_Traps', 'OneMoreHorde_Turrets']


def main():
    parent = ROOT / 'diagnostics/release-tool-tests'
    parent.mkdir(parents=True, exist_ok=True)
    project = Path(tempfile.mkdtemp(prefix='workshop-', dir=parent))
    (project / 'tools').mkdir()
    for name in ['OMH-WorkshopCommon.ps1', 'OMH-SteamHelpers.ps1', 'Stage-Workshop.ps1', 'Publish-OMHWorkshop.ps1', 'OMH-Release.ps1']:
        shutil.copy2(ROOT / 'tools' / name, project / 'tools' / name)
    for name in ['preview.png']:
        shutil.copy2(ROOT / name, project / name)
    (project / 'workshop.txt').write_text('version=1\nid=\ntitle=OMH: Turrets & Traps\ndescription=Fixture development build.\ntags=Build 42\nvisibility=unlisted\n')
    (project / '.gitignore').write_text('/diagnostics/\n/local/\n')
    (project / 'Source').mkdir()
    (project / 'Source/version.txt').write_text('fixture source')
    (project / 'docs').mkdir()
    (project / 'docs/RELEASE.md').write_text('# Fixture releases\n')
    (project / 'WORKSHOP_CHANGELOG.txt').write_text('v9.1.2\n\nDevelopment test content\n\n- Fixture change.\n')
    for package in IDS:
        info = project / 'Contents/mods' / package / '42.20/mod.info'
        info.parent.mkdir(parents=True)
        info.write_text(f'name={package}\nid={package}\nmodversion=9.1.2\n')
    helper = project / 'tools/OMH-SteamHelpers.ps1'
    helper.write_text(helper.read_text(encoding='utf-8') + r'''
function Assert-ProjectZomboidClosed {}
function Get-PublisherCredential {
    return [Management.Automation.PSCredential]::new('fixture', (ConvertTo-SecureString 'fixture' -AsPlainText -Force))
}
function Get-SteamPath { return 'fixture-no-steam.exe' }
function Read-GuardCode { return 'FAKE1' }
function Stop-SteamClient { param([string]$SteamPath); return $false }
function Invoke-SteamCmdUpload {
    param($Credential, $GuardCode, $LogPath)
    $vdf = Get-Content -LiteralPath $vdfPath -Raw
    if ($vdf -notmatch '"visibility" "3"' -or $vdf -match '"(?:title|description|previewfile|tags)"') { throw 'Wrong update fields.' }
    if ($vdf -notmatch '"publishedfileid" "9912345678"') { throw 'Wrong target.' }
    if ($vdf -notmatch '"contentfolder" "([^"\r\n]+)"') { throw 'Missing snapshot.' }
    $content = $Matches[1]
    if (-not $content.StartsWith($snapshot)) { throw 'Upload must use the frozen snapshot.' }
    [IO.File]::WriteAllText($LogPath, 'Fixture Steam result; no Steam process was launched.')
    if ($env:OMHTT_TEST_FAIL_UPLOAD -eq '1') { throw 'Injected Steam failure.' }
    [IO.File]::WriteAllText((Join-Path $repoRoot 'Contents/mods/OneMoreHorde_Traps/42.20/mod.info'), 'changed after snapshot')
    Assert-TTHashes $content $release.Files
}
''', encoding='utf-8')
    user = project / 'local'
    stage = user / 'Workshop/OneMoreHorde_TurretsAndTraps'
    checks = []

    def run(args, success=True, input_text=None, extra_env=None):
        env = os.environ.copy()
        env.update(extra_env or {})
        result = subprocess.run(args, cwd=project, input=input_text, text=True, capture_output=True, env=env)
        assert (result.returncode == 0) == success, result.stdout + result.stderr
        return result.stdout + result.stderr

    def git(*args):
        return run(['git', '-c', f'safe.directory={project.as_posix()}', '-c', 'user.name=Workshop Fixture', '-c', 'user.email=fixture@example.invalid', *args])

    def script(name, *args, **kwargs):
        return run([str(SHELL), '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', str(project / 'tools' / name), '-UserDataRoot', str(user), *args], **kwargs)

    def hash_tree(path):
        return {str(p.relative_to(path)): hashlib.sha256(p.read_bytes()).hexdigest() for p in path.rglob('*') if p.is_file()}

    git('init', '-b', 'fixture')
    git('add', '.')
    git('commit', '-m', 'Fixture')
    git('tag', '-a', 'test/v9.1.2', '-m', 'Fixture')
    script('Stage-Workshop.ps1', '-ValidateOnly')
    assert not user.exists() and not (project / 'diagnostics').exists()
    checks.append('read-only stage preflight')
    script('Stage-Workshop.ps1')
    assert hash_tree(stage / 'Contents') == hash_tree(project / 'Contents')
    assert 'visibility=unlisted' in (stage / 'workshop.txt').read_text()
    checks.append('first native stage and both package hashes')
    assert 'Initial in-game upload is pending' in script('Publish-OMHWorkshop.ps1', '-PreflightOnly', success=False)
    checks.append('no item creation before the native ID exists')
    metadata = stage / 'workshop.txt'
    metadata.write_text(metadata.read_text().replace('id=\n', 'id=9912345678\n') + 'description=Owner page text retained.\n')
    retained = metadata.read_bytes()
    script('Stage-Workshop.ps1')
    assert metadata.read_bytes() == retained
    checks.append('native ID and owner metadata survive repeat staging')
    before = hash_tree(project / 'diagnostics')
    output = script('Publish-OMHWorkshop.ps1', '-PreflightOnly')
    assert '"visibility" "3"' in output and '"publishedfileid" "9912345678"' in output
    assert all(f'"{field}"' not in output for field in ['title', 'description', 'previewfile', 'tags'])
    assert before == hash_tree(project / 'diagnostics')
    assert 'id=\n' in (project / 'workshop.txt').read_text()
    checks.append('offline update preflight preserves metadata and writes nothing')
    for invalid in ['3777891317', '3803035618', '0', 'garbage', '99999999999999999999']:
        metadata.write_text(retained.decode().replace('9912345678', invalid))
        script('Publish-OMHWorkshop.ps1', '-PreflightOnly', success=False)
    metadata.write_bytes(retained)
    checks.append('sibling, zero, malformed and overflow IDs rejected')
    source_meta = project / 'workshop.txt'
    original_meta = source_meta.read_bytes()
    source_meta.write_text(source_meta.read_text().replace('id=\n', 'id=9987654321\n'))
    script('Publish-OMHWorkshop.ps1', '-PreflightOnly', success=False)
    source_meta.write_bytes(original_meta)
    checks.append('conflicting source/staged IDs rejected')
    item = project / 'Contents/mods' / IDS[0] / '42.20/mod.info'
    original = item.read_bytes()
    item.write_text('changed source')
    script('Stage-Workshop.ps1', '-ValidateOnly', success=False)
    item.write_bytes(original)
    extra = item.parent / 'untracked.txt'
    extra.write_text('do not ship')
    script('Stage-Workshop.ps1', '-ValidateOnly', success=False)
    extra.unlink()
    checks.append('changed and untracked gameplay rejected')
    staged_info = stage / 'Contents/mods' / IDS[0] / '42.20/mod.info'
    staged_info.write_text('owner modified staged content')
    script('Stage-Workshop.ps1', success=False)
    assert staged_info.read_text() == 'owner modified staged content'
    staged_info.write_bytes(original)
    checks.append('edited staged gameplay preserved and refused')
    marker = stage / '.omhtt-workshop-stage.json'
    marker_bytes = marker.read_bytes()
    marker.unlink()
    script('Stage-Workshop.ps1', success=False)
    marker.write_bytes(marker_bytes)
    checks.append('unmanaged stage refused')
    wrapper = project / 'rollback.ps1'
    wrapper.write_text(r'''$ErrorActionPreference = 'Stop'
function Copy-Item {
    param([string]$LiteralPath, [string]$Destination, [switch]$Recurse)
    if ($Destination -eq (Join-Path $PSScriptRoot 'local\Workshop\OneMoreHorde_TurretsAndTraps')) { throw 'Injected stage copy failure' }
    Microsoft.PowerShell.Management\Copy-Item -LiteralPath $LiteralPath -Destination $Destination -Recurse:$Recurse
}
& (Join-Path $PSScriptRoot 'tools/Stage-Workshop.ps1') -UserDataRoot (Join-Path $PSScriptRoot 'local')
''')
    rollback = run([str(SHELL), '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', str(wrapper)], success=False)
    assert 'Injected stage copy failure' in rollback
    assert metadata.read_bytes() == retained and staged_info.read_bytes() == original
    checks.append('failed restaging rolls back the original folder')
    wrapper.write_text(r'''$ErrorActionPreference = 'Stop'
function Copy-Item {
    param([string]$LiteralPath, [string]$Destination, [switch]$Recurse)
    if ($LiteralPath.EndsWith('preview.png')) {
        [IO.File]::AppendAllText((Join-Path $PSScriptRoot 'local\Workshop\OneMoreHorde_TurretsAndTraps\workshop.txt'), "description=Concurrent native edit.`n")
    }
    Microsoft.PowerShell.Management\Copy-Item -LiteralPath $LiteralPath -Destination $Destination -Recurse:$Recurse
}
& (Join-Path $PSScriptRoot 'tools/Stage-Workshop.ps1') -UserDataRoot (Join-Path $PSScriptRoot 'local')
''')
    result = run([str(SHELL), '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', str(wrapper)], success=False)
    assert 'game changed Workshop metadata' in result
    assert 'Concurrent native edit.' in metadata.read_text() and staged_info.read_bytes() == original
    metadata.write_bytes(retained)
    checks.append('concurrent native metadata change refuses replacement and preserves the edit')
    before = hash_tree(project / 'diagnostics')
    script('Publish-OMHWorkshop.ps1', input_text='CANCEL\n', success=False)
    assert before == hash_tree(project / 'diagnostics')
    checks.append('cancelled upload changes nothing')
    changelog = (project / 'WORKSHOP_CHANGELOG.txt').read_bytes()
    script('Publish-OMHWorkshop.ps1', input_text=' publish \n')
    assert 'id=9912345678' in source_meta.read_text()
    assert (project / 'WORKSHOP_CHANGELOG.txt').read_bytes() == changelog
    receipts = list((project / 'diagnostics/workshop').glob('upload-*/upload-result.json'))
    assert len(receipts) == 1 and json.loads(receipts[0].read_text())['status'] == 'confirmed'
    assert 'Confirmed unlisted development upload' in (project / 'docs/RELEASE.md').read_text()
    item.write_bytes(original)
    checks.append('simulated success records exact snapshot and ID without clearing notes')
    git('add', 'workshop.txt', 'docs/RELEASE.md')
    git('commit', '-m', 'Fixture identity')
    release_before = (project / 'docs/RELEASE.md').read_bytes()
    script('Publish-OMHWorkshop.ps1', input_text='PUBLISH\n', extra_env={'OMHTT_TEST_FAIL_UPLOAD': '1'}, success=False)
    receipts = list((project / 'diagnostics/workshop').glob('upload-*/upload-result.json'))
    assert sorted(json.loads(p.read_text())['status'] for p in receipts) == ['confirmed', 'pending']
    assert (project / 'docs/RELEASE.md').read_bytes() == release_before
    assert (project / 'WORKSHOP_CHANGELOG.txt').read_bytes() == changelog
    checks.append('failed upload keeps pending evidence and leaves baseline untouched')
    report = {'checks': checks, 'fixture': str(project), 'steamCalls': 0}
    (parent / 'workshop-results.json').write_text(json.dumps(report, indent=2))
    print(f'PASS: {len(checks)} Workshop checks; no Steam calls. Fixture: {project}')


if __name__ == '__main__':
    main()
