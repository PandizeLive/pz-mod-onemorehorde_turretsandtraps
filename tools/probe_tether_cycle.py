import hashlib
import json
import os
import re
import shutil
import subprocess
import time
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GAME = Path(os.environ.get("PZ_GAME_DIR", "C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid"))
OUTPUT = ROOT / "diagnostics/tether-cycle"
MARKER = "[OMHTT-TetherCycle]"


def package_preview():
    source = ROOT / "tools/prototypes/tether"
    OUTPUT.mkdir(parents=True, exist_ok=True)
    archive = OUTPUT / "OMHTT_TetherPrototype.zip"
    with zipfile.ZipFile(archive, "w", zipfile.ZIP_DEFLATED) as bundle:
        for layer in ["common", "42.20"]:
            for directory in ["AnimSets", "actiongroups", "lua/shared", "lua/client", "lua/server"]:
                bundle.writestr(f"OMHTT_TetherPrototype/{layer}/media/{directory}/", "")
        for path in sorted(source.rglob("*")):
            if path.is_file():
                bundle.write(path, "OMHTT_TetherPrototype/" + path.relative_to(source).as_posix())
    return archive


def main():
    source = ROOT / "tools/prototypes/tether"
    for path in source.rglob("*.lua"):
        text = path.read_text(encoding="utf-8")
        assert not re.search(r"\b(?:pcall|xpcall|ipairs|next)\s*\(", text), path
        assert "\t" not in text and not text.startswith("\ufeff"), path
    for path in source.rglob("*.json"):
        json.loads(path.read_text(encoding="utf-8"))
    package_preview()
    cache = OUTPUT / "cache"
    package = cache / "mods/OMHTT_TetherPrototype"
    shutil.copytree(source, package, dirs_exist_ok=True)
    for layer in ["common", "42.20"]:
        for directory in ["AnimSets", "actiongroups", "lua/shared", "lua/client", "lua/server"]:
            (package / layer / "media" / directory).mkdir(parents=True, exist_ok=True)
    shutil.copyfile(ROOT / "tools/tests/tether_prototype.lua",
                    package / "42.20/media/lua/server/TetherCycleCheck.lua")
    client = (source / "42.20/media/lua/client/OMHTTTether/View.lua").read_text(encoding="utf-8")
    assert "]====]" not in client
    (package / "42.20/media/lua/server/TetherClientSyntax.lua").write_text(
        'assert(loadstring([====[' + client + ']====]), "Client renderer syntax")\n'
        'print("[OMHTT-TetherCycle] clientSyntax=true")\n', encoding="utf-8")
    config = cache / "Server/OMHTT_TetherCycle.ini"
    config.parent.mkdir(parents=True, exist_ok=True)
    config.write_text(
        "Mods=OMHTT_TetherPrototype\nMap=Muldraugh, KY\nPublic=false\nPauseEmpty=true\n"
        "UPnP=false\nDefaultPort=29341\nUDPPort=29342\n", encoding="utf-8")
    command = [
        str(GAME / "jre64/bin/java.exe"), "--enable-native-access=ALL-UNNAMED",
        "--add-exports=java.base/jdk.internal.misc=ALL-UNNAMED", "-XX:-CreateCoredumpOnCrash", "-Xmx1536m",
        "-Djava.library.path=./natives/;./natives/win64/;./", "-cp", "projectzomboid.jar",
        "zombie.network.GameServer", "-cachedir=" + str(cache), "-servername", "OMHTT_TetherCycle",
        "-nosteam", "-ip", "127.0.0.1", "-port", "29341", "-adminusername", "probe", "-adminpassword", "local-probe",
    ]
    transcript = OUTPUT / "native.log"
    started = time.monotonic()
    with transcript.open("w", encoding="utf-8") as stream:
        process = subprocess.Popen(command, cwd=GAME, stdin=subprocess.PIPE, stdout=stream,
                                   stderr=subprocess.STDOUT, text=True, creationflags=subprocess.CREATE_NO_WINDOW)
        try:
            while process.poll() is None and time.monotonic() - started < 150:
                output = transcript.read_text(encoding="utf-8", errors="replace")
                if MARKER + " completed=true" in output:
                    process.stdin.write("quit\n")
                    process.stdin.flush()
                    process.wait(timeout=40)
                    break
                if 'Exception in thread "main"' in output or "java.lang.RuntimeException:" in output:
                    raise RuntimeError("Native test failed: " + str(transcript))
                time.sleep(.25)
            else:
                raise RuntimeError("No completed test marker: " + str(transcript))
        finally:
            if process.poll() is None:
                process.terminate()
                process.wait(timeout=15)
    output = transcript.read_text(encoding="utf-8", errors="replace")
    assert "Shutdown handling finished" in output
    assert MARKER + " clientSyntax=true" in output
    report = {
        "seconds": round(time.monotonic() - started, 1),
        "gameJarSha256": hashlib.sha256((GAME / "projectzomboid.jar").read_bytes()).hexdigest(),
        "reports": [line[line.index(MARKER):] for line in output.splitlines() if MARKER in line],
        "prototypeHashes": {p.relative_to(source).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest()
                            for p in sorted(source.rglob("*")) if p.is_file()},
        "limitations": "No connected clients or rendered-world test; synthetic wall/cell lookup with native actor/square.",
    }
    (OUTPUT / "result.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
