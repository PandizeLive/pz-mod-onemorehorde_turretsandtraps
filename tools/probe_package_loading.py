import argparse
import hashlib
import json
import os
import subprocess
import time
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
GAME = Path(os.environ.get("PZ_GAME_DIR", "C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid"))
OUTPUT = ROOT / "diagnostics/package-loading"


def write(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(value, encoding="utf-8")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--selection", choices=["base", "addon", "both", "reverse"], default="addon")
    selection = parser.parse_args().selection
    OUTPUT.mkdir(parents=True, exist_ok=True)
    cache = OUTPUT / "cache"
    definitions = [
        ("OMHTT_LoadProbe_Base", ""),
        ("OMHTT_LoadProbe_Addon", "require=OMHTT_LoadProbe_Base\n"),
    ]
    for identifier, dependency in definitions:
        package = cache / "mods" / identifier
        for layer in ["common", "42.20"]:
            for directory in ["AnimSets", "actiongroups", "lua/shared", "lua/server", "lua/client"]:
                (package / layer / "media" / directory).mkdir(parents=True, exist_ok=True)
        write(package / "42.20/mod.info", f"name={identifier}\nid={identifier}\nmodversion=0.0.1\nversionMin=42.20\n{dependency}")
        write(package / "42.20/media/lua/shared/OMHTTLoadProbe/Shared.lua",
              'OMHTTLoadProbe = OMHTTLoadProbe or {runs = 0}\nOMHTTLoadProbe.runs = OMHTTLoadProbe.runs + 1\nreturn OMHTTLoadProbe\n')
    probe = '''local shared = require("OMHTTLoadProbe/Shared")
local function checkLoading()
    assert(shared.runs == 1, "Shared Lua executed more than once")
    assert(getActivatedMods():contains("OMHTT_LoadProbe_Base"), "Required entry did not load")
    assert(getActivatedMods():contains("OMHTT_LoadProbe_Addon") == EXPECT_ADDON, "Unexpected addon loading")
    print("[OMHTT-Packages] sharedRuns=1 selection=SELECTION game=" .. getCore():getVersionNumber())
end
Events.OnServerStarted.Add(checkLoading)
'''
    probe = probe.replace("EXPECT_ADDON", "false" if selection == "base" else "true").replace("SELECTION", selection)
    write(cache / "mods/OMHTT_LoadProbe_Base/42.20/media/lua/server/OMHTT_LoadProbe.lua", probe)
    selections = {"base": definitions[0][0], "addon": definitions[1][0],
                  "both": definitions[0][0] + ";" + definitions[1][0],
                  "reverse": definitions[1][0] + ";" + definitions[0][0]}
    write(cache / "Server/OMHTT_LoadProbe.ini", "Mods=" + selections[selection] + "\nMap=Muldraugh, KY\nPublic=false\nPauseEmpty=true\nUPnP=false\nDefaultPort=29261\nUDPPort=29262\n")
    command = [str(GAME / "jre64/bin/java.exe"), "--enable-native-access=ALL-UNNAMED",
               "--add-exports=java.base/jdk.internal.misc=ALL-UNNAMED", "-XX:-CreateCoredumpOnCrash", "-Xmx1536m",
               "-Djava.library.path=./natives/;./natives/win64/;./", "-cp", "projectzomboid.jar;.",
               "zombie.network.GameServer", "-cachedir=" + str(cache), "-servername", "OMHTT_LoadProbe",
               "-nosteam", "-ip", "127.0.0.1", "-port", "29261", "-adminusername", "probe", "-adminpassword", "local-probe"]
    transcript = OUTPUT / (selection + ".log")
    with transcript.open("w", encoding="utf-8") as stream:
        process = subprocess.Popen(command, cwd=GAME, stdin=subprocess.PIPE, stdout=stream, stderr=subprocess.STDOUT,
                                   text=True, creationflags=subprocess.CREATE_NO_WINDOW)
        started = time.monotonic()
        try:
            while process.poll() is None and time.monotonic() - started < 150:
                output = transcript.read_text(encoding="utf-8", errors="replace")
                if "[OMHTT-Packages] sharedRuns=1 selection=" + selection in output:
                    process.stdin.write("quit\n")
                    process.stdin.flush()
                    process.wait(timeout=40)
                    break
                if 'Exception in thread "main"' in output or "OMHTT_LoadProbe.lua:" in output:
                    raise RuntimeError("Native loading probe failed; inspect " + str(transcript))
                time.sleep(0.25)
            else:
                raise RuntimeError("Native loading probe did not finish; inspect " + str(transcript))
        finally:
            if process.poll() is None:
                process.terminate()
                process.wait(timeout=15)
    output = transcript.read_text(encoding="utf-8", errors="replace")
    assert "Shutdown handling finished" in output, "Missing clean shutdown"
    assert "NoSuchFileException" not in output, "Missing package directories"
    with (GAME / "projectzomboid.jar").open("rb") as stream:
        digest = hashlib.file_digest(stream, "sha256").hexdigest()
    result = {"selection": selection, "sharedLuaRuns": 1, "baseLoaded": True, "addonLoaded": selection != "base",
              "gameJarSha256": digest,
              "gameJar": str(GAME / "projectzomboid.jar"), "seconds": round(time.monotonic() - started, 1)}
    write(OUTPUT / (selection + ".json"), json.dumps(result, indent=2) + "\n")
    print(json.dumps(result))


if __name__ == "__main__":
    main()
