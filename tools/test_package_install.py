import hashlib
import json
import os
import shutil
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SHELL = Path(os.environ["SystemRoot"]) / "System32/WindowsPowerShell/v1.0/powershell.exe"
IDS = ["OneMoreHorde_Traps", "OneMoreHorde_Turrets"]
LEGACY = "OneMoreHorde_TurretsAndTraps"


def main():
    parent = ROOT / "diagnostics/release-tool-tests"
    parent.mkdir(parents=True, exist_ok=True)
    project = Path(tempfile.mkdtemp(prefix="split-", dir=parent))
    (project / "tools").mkdir()
    for name in ["OMH-Release.ps1", "Install-Packages.ps1", "OMH-WorkshopCommon.ps1", "OMH-SteamHelpers.ps1", "Publish-OMHWorkshop.ps1"]:
        shutil.copy2(ROOT / "tools" / name, project / "tools" / name)
    (project / "workshop.txt").write_text("version=1\nid=\ntitle=OMH: Turrets & Traps\nvisibility=unlisted\n")
    source = project / "Source/version.txt"
    source.parent.mkdir()
    source.write_text("fixture")
    manifest = {"version": "0.2.29", "sourceFiles": {"version.txt": hashlib.sha256(source.read_bytes()).hexdigest()}, "packages": {}}
    for identifier in IDS:
        info = project / "Contents/mods" / identifier / "42.20/mod.info"
        info.parent.mkdir(parents=True)
        info.write_text("name=" + identifier + "\nid=" + identifier + "\nmodversion=0.2.29\n")
        manifest["packages"][identifier] = {"42.20/mod.info": hashlib.sha256(info.read_bytes()).hexdigest()}
    output = project / "diagnostics/v0.2.29"
    output.mkdir(parents=True)
    (output / "manifest.json").write_text(json.dumps(manifest))
    mods = project / "installed-mods"

    def run(args, success=True):
        result = subprocess.run(args, cwd=project, capture_output=True, text=True)
        assert (result.returncode == 0) == success, result.stdout + result.stderr
        return result.stdout + result.stderr

    def git(*args):
        return run(["git", "-c", "user.name=Release Fixture", "-c", "user.email=fixture@example.invalid", *args])

    def install(*args, success=True, directory=mods):
        return run([str(SHELL), "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(project / "tools/Install-Packages.ps1"),
                    "-ModsDirectory", str(directory), *args], success)

    git("init", "-b", "fixture")
    git("add", "Contents", "Source")
    git("commit", "-m", "Fixture")
    install("-ValidateOnly", success=False)
    git("tag", "-a", "test/v0.2.29", "-m", "Fixture")
    git("branch", "-m", "main")
    install("-ValidateOnly", success=False)
    git("branch", "-m", "fixture")
    install("-ValidateOnly")
    assert not mods.exists()
    legacy = mods / LEGACY
    legacy.mkdir(parents=True)
    (legacy / "mod.info").write_text("legacy combined")
    (legacy / "owner-note.txt").write_text("keep legacy notes")
    (legacy / ".omhtt-foundation-install.json").write_text(json.dumps({"version": "0.2.28", "files": {
        "mod.info": hashlib.sha256((legacy / "mod.info").read_bytes()).hexdigest()}}))
    install()
    assert not legacy.exists()
    legacy_backups = list((project / "diagnostics/p1c1/install-backups").glob("*/" + LEGACY))
    assert len(legacy_backups) == 1 and (legacy_backups[0] / "owner-note.txt").read_text() == "keep legacy notes"
    for identifier in IDS:
        assert (mods / identifier / "42.20/mod.info").read_bytes() == (project / "Contents/mods" / identifier / "42.20/mod.info").read_bytes()
    (mods / IDS[0] / "owner-note.txt").write_text("keep current notes")
    install()
    assert (mods / IDS[0] / "owner-note.txt").read_text() == "keep current notes"
    info = project / "Contents/mods" / IDS[1] / "42.20/mod.info"
    original = info.read_bytes()
    info.write_text("changed")
    install("-ValidateOnly", success=False)
    info.write_bytes(original)
    extra = info.parent / "extra.lua"
    extra.write_text("untracked")
    install("-ValidateOnly", success=False)
    extra.unlink()
    source.write_text("changed source")
    install("-ValidateOnly", success=False)
    source.write_text("fixture")
    unmanaged = project / "unmanaged" / IDS[0]
    unmanaged.mkdir(parents=True)
    install(success=False, directory=unmanaged.parent)
    assert not list(unmanaged.iterdir())
    installed_file = mods / IDS[0] / "42.20/mod.info"
    installed_original = installed_file.read_bytes()
    installed_file.write_text("owner edited managed file")
    install("-ValidateOnly", success=False)
    assert installed_file.read_text() == "owner edited managed file"
    installed_file.write_bytes(installed_original)
    failure_script = project / "fail-install.ps1"
    failure_script.write_text('''$ErrorActionPreference = 'Stop'
function Move-Item {
    param([string]$LiteralPath, [string]$Destination)
    if ($LiteralPath -like '*install-stage*' -and $Destination.EndsWith('OneMoreHorde_Turrets')) { throw 'Injected second-package failure' }
    Microsoft.PowerShell.Management\\Move-Item -LiteralPath $LiteralPath -Destination $Destination
}
& (Join-Path $PSScriptRoot 'tools/Install-Packages.ps1') -ModsDirectory (Join-Path $PSScriptRoot 'installed-mods')
''')
    rollback = run([str(SHELL), "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(failure_script)], success=False)
    assert "Injected second-package failure" in rollback
    for identifier in IDS:
        assert (mods / identifier / "42.20/mod.info").read_bytes() == (project / "Contents/mods" / identifier / "42.20/mod.info").read_bytes()
    assert (mods / IDS[0] / "owner-note.txt").read_text() == "keep current notes"
    run([str(SHELL), "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(project / "tools/OMH-Release.ps1"), "-Action", "Mirror", "-ValidateOnly"], success=False)
    pending = run([str(SHELL), "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(project / "tools/OMH-Release.ps1"), "-Action", "Publish", "-ValidateOnly", "-UserDataRoot", str(project / "user-data")], success=False)
    assert "Initial in-game upload is pending" in pending
    summary = "PASS: two-package install, legacy retirement/full backup, repeat install, owner-file preservation, transactional rollback, read-only readiness, modified/untracked/unmanaged refusal, branch/tag gates, native-first publication gate."
    (parent / "install-results.log").write_text(summary + "\nFixture: " + str(project) + "\n")
    print(summary)


if __name__ == "__main__":
    main()
