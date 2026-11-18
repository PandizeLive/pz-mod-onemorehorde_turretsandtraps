import argparse
import json
import os
import shutil
import subprocess
import time

from build_packages import IDS, ROOT, build
from pathlib import Path

GAME = Path(os.environ.get("PZ_GAME_DIR", "C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid"))


def check(selection):
    version, expected = build(check=True)
    output = Path(os.environ.get("OMHTT_DIAGNOSTIC_DIR", str(ROOT / "diagnostics" / ("v" + version))))
    output.mkdir(parents=True, exist_ok=True)
    cache = output / ("package-cache-" + selection)
    selected = ["traps"] if selection == "traps" else ["turrets"] if selection == "turrets" else ["turrets", "traps"]
    for component, files in expected.items():
        package = cache / "mods" / IDS[component]
        for relative, content in files.items():
            path = package / relative
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(content)
    probe = cache / "mods" / IDS[selected[0]] / "42.20/media/lua/server/OMHTT_PackageSmoke.lua"
    text = (ROOT / "tools/tests/native_packages.lua").read_text()
    text = text.replace("EXPECT_TRAPS", "true" if "traps" in selected else "false").replace("EXPECT_TURRETS", "true" if "turrets" in selected else "false")
    probe.write_text(text, encoding="utf-8")
    settings = cache / "Server/OMHTT_Packages.ini"
    settings.parent.mkdir(parents=True, exist_ok=True)
    settings.write_text("Mods=" + ";".join(IDS[c] for c in selected) + "\nPublic=false\nPauseEmpty=true\nUPnP=false\nMap=Muldraugh, KY\nDefaultPort=29361\nUDPPort=29362\n")
    command = [str(GAME / "jre64/bin/java.exe"), "--enable-native-access=ALL-UNNAMED", "-Xmx1536m",
               "-Djava.library.path=./natives/;./natives/win64/;./", "-cp", "projectzomboid.jar;.",
               "zombie.network.GameServer", "-cachedir=" + str(cache), "-servername", "OMHTT_Packages", "-nosteam",
               "-ip", "127.0.0.1", "-port", "29361", "-adminusername", "probe", "-adminpassword", "local-probe"]
    transcript = output / ("packages-" + selection + ".log")
    started = time.monotonic()
    with transcript.open("w", encoding="utf-8") as stream:
        process = subprocess.Popen(command, cwd=GAME, stdin=subprocess.PIPE, stdout=stream, stderr=subprocess.STDOUT,
                                   text=True, creationflags=subprocess.CREATE_NO_WINDOW)
        try:
            while process.poll() is None and time.monotonic() - started < 150:
                text = transcript.read_text(encoding="utf-8", errors="replace")
                if "[OMHTT-Packages] PASS" in text:
                    process.stdin.write("quit\n")
                    process.stdin.flush()
                    process.wait(timeout=40)
                    break
                if 'Exception in thread "main"' in text or "OMHTT_PackageSmoke.lua:" in text:
                    raise RuntimeError("Native package test failed: " + str(transcript))
                time.sleep(0.25)
            else:
                raise RuntimeError("Package startup did not finish: " + str(transcript))
        finally:
            if process.poll() is None:
                process.terminate()
                process.wait(timeout=15)
            probe.unlink(missing_ok=True)
    text = transcript.read_text(encoding="utf-8", errors="replace")
    assert "[OMHTT] packages-ready version=" + version + " " in text, "Runtime version differs from packaged version"
    assert "Shutdown handling finished" in text
    assert "NoSuchFileException" not in text
    assert "tiledef number" not in text.lower()
    assert text.count("[OMHTT] packages-ready") == 1, "Shared startup hook duplicated"
    assert not any("MOD:OMH:" in line and "Exception thrown" in line for line in text.splitlines()), "Mod startup callback failed"
    result = {"selection": selection, "version": version, "passed": True, "seconds": round(time.monotonic() - started, 1)}
    (output / ("packages-" + selection + ".json")).write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(result), flush=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--selection", choices=["traps", "turrets", "both", "all"], default="all")
    selected = parser.parse_args().selection
    for selection in (["traps", "turrets", "both"] if selected == "all" else [selected]):
        check(selection)
