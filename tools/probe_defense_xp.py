import hashlib
import json
import os
import subprocess
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GAME = Path(os.environ.get("PZ_GAME_DIR", "C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid"))
OUTPUT = ROOT / "diagnostics/defense-xp-feasibility"
MARKER = "[OMHTT-XPProbe]"


def write(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(value, encoding="utf-8", newline="\n")


def main():
    cache = OUTPUT / "cache"
    package = cache / "mods/OMHTT_XPProbe"
    for layer in ["common", "42.20"]:
        for folder in ["AnimSets", "actiongroups", "lua/shared", "lua/server", "lua/client"]:
            (package / layer / "media" / folder).mkdir(parents=True, exist_ok=True)
    write(package / "42.20/mod.info", "name=OMHTT Isolated XP Probe\nid=OMHTT_XPProbe\nmodversion=0.0.1\nversionMin=42.20\n")
    write(package / "42.20/media/lua/server/XPProbe.lua", (ROOT / "tools/tests/native_defense_xp.lua").read_text(encoding="utf-8"))
    write(package / "42.20/media/lua/server/WoundProbe.lua", (ROOT / "tools/tests/native_wound_attribution.lua").read_text(encoding="utf-8"))
    write(cache / "Server/OMHTT_XPProbe.ini", "Mods=OMHTT_XPProbe\nMap=Muldraugh, KY\nPublic=false\nPauseEmpty=true\nUPnP=false\nDefaultPort=29341\nUDPPort=29342\n")
    classes = OUTPUT / "classes"
    classes.mkdir(parents=True, exist_ok=True)
    subprocess.run(["C:/Program Files/Java/jdk-17/bin/javac.exe", "-d", str(classes),
                    str(ROOT / "tools/NativeDefenseXPProbe.java")], check=True)
    command = [str(GAME / "jre64/bin/java.exe"), "--enable-native-access=ALL-UNNAMED",
               "--add-exports=java.base/jdk.internal.misc=ALL-UNNAMED", "-XX:-CreateCoredumpOnCrash", "-Xmx1536m",
               "-Djava.library.path=./natives/;./natives/win64/;./", "-cp", str(classes) + ";projectzomboid.jar", "NativeDefenseXPProbe",
               "-cachedir=" + str(cache), "-servername", "OMHTT_XPProbe", "-nosteam", "-ip", "127.0.0.1",
               "-port", "29341", "-adminusername", "probe", "-adminpassword", "local-probe"]
    transcript = OUTPUT / "native-xp.log"
    started = time.monotonic()
    with transcript.open("w", encoding="utf-8") as stream:
        process = subprocess.Popen(command, cwd=GAME, stdin=subprocess.PIPE, stdout=stream, stderr=subprocess.STDOUT,
                                   text=True, creationflags=subprocess.CREATE_NO_WINDOW)
        try:
            while process.poll() is None and time.monotonic() - started < 160:
                output = transcript.read_text(encoding="utf-8", errors="replace")
                if MARKER + " packetCompleted=true" in output or MARKER + " packetFailed=true" in output:
                    process.stdin.write("quit\n")
                    process.stdin.flush()
                    process.wait(timeout=40)
                    break
                if 'Exception in thread "main"' in output:
                    raise RuntimeError("Native startup failed")
                time.sleep(.25)
            else:
                raise RuntimeError("Native probe did not finish")
        finally:
            if process.poll() is None:
                process.terminate()
                process.wait(timeout=15)
    output = transcript.read_text(encoding="utf-8", errors="replace")
    lines = [line[line.index(MARKER):] for line in output.splitlines() if MARKER in line]
    result = {"seconds": round(time.monotonic() - started, 1), "reports": lines,
              "success": MARKER + " completed=true" in output and MARKER + " packetCompleted=true" in output
                         and "Shutdown handling finished" in output,
              "jarSha256": hashlib.sha256((GAME / "projectzomboid.jar").read_bytes()).hexdigest(),
              "scope": "Native synthetic actors on a zero-client stock server; not live client transport or a complete attribution proof."}
    write(OUTPUT / "result.json", json.dumps(result, indent=2) + "\n")
    print(json.dumps(result, indent=2))
    if not result["success"]:
        raise RuntimeError("Native probe failed; inspect " + str(transcript))


if __name__ == "__main__":
    main()
