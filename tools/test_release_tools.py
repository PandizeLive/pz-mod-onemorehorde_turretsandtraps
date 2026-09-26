import hashlib
import json
import os
import shutil
import subprocess
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SHELL = Path(os.environ["SystemRoot"]) / "System32/WindowsPowerShell/v1.0/powershell.exe"
ID = "OneMoreHorde_TurretsAndTraps"


def main():
    parent = ROOT / "diagnostics/release-tool-tests"
    parent.mkdir(parents=True, exist_ok=True)
    project = Path(tempfile.mkdtemp(prefix="fixture-", dir=parent))
    (project / "tools").mkdir()
    for name in ["OMH-Release.ps1", "Install-Foundation.ps1"]:
        shutil.copy2(ROOT / "tools" / name, project / "tools" / name)
    package = project / "Contents/mods" / ID
    (package / "42.20").mkdir(parents=True)
    info = package / "42.20/mod.info"
    info.write_text("name=OMH: Turrets & Traps\nid=" + ID + "\nmodversion=0.1.6\n")
    manifest = {"version": "0.1.6", "files": {"42.20/mod.info": hashlib.sha256(info.read_bytes()).hexdigest()}}
    output = project / "diagnostics/v0.1.6"
    output.mkdir(parents=True)
    (output / "manifest.json").write_text(json.dumps(manifest))
    mods = project / "installed-mods"

    def run(args, success=True):
        result = subprocess.run(args, cwd=project, capture_output=True, text=True)
        assert (result.returncode == 0) == success, result.stdout + result.stderr
        return result.stdout

    def git(*args):
        return run(["git", "-c", "user.name=Release Fixture", "-c", "user.email=fixture@example.invalid", *args])

    def install(*args, success=True):
        return run([str(SHELL), "-NoProfile", "-ExecutionPolicy", "Bypass", "-File",
                    str(project / "tools/Install-Foundation.ps1"), "-ModsDirectory", str(mods), *args], success)

    git("init", "-b", "fixture")
    git("add", "Contents")
    git("commit", "-m", "Fixture")
    install("-ValidateOnly", success=False)
    assert not mods.exists()
    git("tag", "-a", "test/v0.1.6", "-m", "Fixture")
    git("branch", "-m", "main")
    install("-ValidateOnly", success=False)
    git("branch", "-m", "fixture")
    install("-ValidateOnly")
    assert not mods.exists()
    install()
    destination = mods / ID
    assert (destination / "42.20/mod.info").read_bytes() == info.read_bytes()
    (destination / "owner-note.txt").write_text("keep me")
    install()
    backups = list((project / "diagnostics/p1c1/install-backups").glob("*/" + ID))
    assert len(backups) == 1 and (backups[0] / "owner-note.txt").read_text() == "keep me"
    assert (destination / "owner-note.txt").read_text() == "keep me"
    original = info.read_bytes()
    info.write_text("changed")
    install("-ValidateOnly", success=False)
    assert (destination / "42.20/mod.info").read_bytes() == original
    info.write_bytes(original)
    (package / "untracked.lua").write_text("bad")
    install("-ValidateOnly", success=False)
    (package / "untracked.lua").unlink()
    unmanaged = project / "unmanaged" / ID
    unmanaged.mkdir(parents=True)
    result = subprocess.run([str(SHELL), "-NoProfile", "-ExecutionPolicy", "Bypass", "-File",
        str(project / "tools/Install-Foundation.ps1"), "-ModsDirectory", str(unmanaged.parent)], capture_output=True)
    assert result.returncode != 0 and not list(unmanaged.iterdir())
    for action in ["Mirror", "Publish"]:
        run([str(SHELL), "-NoProfile", "-ExecutionPolicy", "Bypass", "-File",
            str(project / "tools/OMH-Release.ps1"), "-Action", action, "-ValidateOnly"], False)
    summary = ("Release tools passed: missing-tag/main-branch refusal, read-only readiness, install hashes, full backup, "
               "owner-file preservation, modified/untracked source refusal, unmanaged-folder refusal, and unavailable remote actions.\n")
    print(summary + "Fixtures: " + str(project))
    version = (ROOT / "Contents/mods" / ID / "42.20/mod.info").read_text().split("modversion=", 1)[1].splitlines()[0]
    evidence = ROOT / "diagnostics" / ("v" + version)
    evidence.mkdir(parents=True, exist_ok=True)
    (evidence / "release-tools.log").write_text(summary + str(project) + "\n")


if __name__ == "__main__":
    main()
