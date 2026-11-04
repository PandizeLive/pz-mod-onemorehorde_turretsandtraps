import hashlib
import json
import os
import subprocess
import time
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
GAME = Path(os.environ.get("PZ_GAME_DIR", "C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid"))
JAVAP = Path("C:/Program Files/Java/jdk-17/bin/javap.exe")
OUTPUT = ROOT / "diagnostics/tether-feasibility"
MARKER = "[OMHTT-TetherAPI]"


def write(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(value, encoding="utf-8", newline="\n")


def inspect_bytecode():
    classes = [
        "zombie.core.physics.Bullet",
        "zombie.vehicles.BaseVehicle",
        "zombie.Lua.LuaManager$Exposer",
        "zombie.core.physics.WorldSimulation",
        "zombie.characters.animals.IsoAnimal",
    ]
    for name in classes:
        result = subprocess.run(
            [str(JAVAP), "-classpath", str(GAME / "projectzomboid.jar"), "-c", "-p", name],
            capture_output=True, text=True, check=True, encoding="utf-8",
        )
        write(OUTPUT / (name + ".bytecode.txt"), result.stdout)


def main():
    inspect_bytecode()
    cache = OUTPUT / "cache"
    package = cache / "mods/OMHTT_TetherAPI"
    for layer in ["common", "42.20"]:
        for directory in ["AnimSets", "actiongroups", "lua/shared", "lua/server", "lua/client"]:
            (package / layer / "media" / directory).mkdir(parents=True, exist_ok=True)
    write(package / "42.20/mod.info",
          "name=OMHTT Isolated Tether API Probe\nid=OMHTT_TetherAPI\nmodversion=0.0.1\nversionMin=42.20\n")
    write(package / "42.20/media/lua/server/TetherAPI.lua", '''
local function report()
    print("[OMHTT-TetherAPI] game=" .. getCore():getVersionNumber())
    print("[OMHTT-TetherAPI] Bullet=" .. type(Bullet) .. " WorldSimulation=" .. type(WorldSimulation)
        .. " luajava=" .. type(luajava))
    local vehicle = BaseVehicle.new(getCell())
    print("[OMHTT-TetherAPI] vehicle=" .. tostring(vehicle ~= nil)
        .. " addPointConstraint=" .. type(vehicle.addPointConstraint)
        .. " canAttachTrailer=" .. type(vehicle.canAttachTrailer)
        .. " breakConstraint=" .. type(vehicle.breakConstraint)
        .. " applyImpulseGeneric=" .. type(vehicle.applyImpulseGeneric))
    print("[OMHTT-TetherAPI] completed=true spawnedObjects=0 physicsSimulationTested=false")
end
Events.OnServerStarted.Add(report)
''')
    write(cache / "Server/OMHTT_TetherAPI.ini",
          "Mods=OMHTT_TetherAPI\nMap=Muldraugh, KY\nPublic=false\nPauseEmpty=true\nUPnP=false\n"
          "DefaultPort=29331\nUDPPort=29332\n")
    command = [
        str(GAME / "jre64/bin/java.exe"), "--enable-native-access=ALL-UNNAMED",
        "--add-exports=java.base/jdk.internal.misc=ALL-UNNAMED",
        "-XX:-CreateCoredumpOnCrash", "-Xmx1536m",
        "-Djava.library.path=./natives/;./natives/win64/;./",
        "-cp", "projectzomboid.jar", "zombie.network.GameServer",
        "-cachedir=" + str(cache), "-servername", "OMHTT_TetherAPI",
        "-nosteam", "-ip", "127.0.0.1", "-port", "29331",
        "-adminusername", "probe", "-adminpassword", "local-probe",
    ]
    transcript = OUTPUT / "native-api.log"
    started = time.monotonic()
    with transcript.open("w", encoding="utf-8") as stream:
        process = subprocess.Popen(
            command, cwd=GAME, stdin=subprocess.PIPE, stdout=stream, stderr=subprocess.STDOUT,
            text=True, creationflags=subprocess.CREATE_NO_WINDOW,
        )
        try:
            while process.poll() is None and time.monotonic() - started < 150:
                output = transcript.read_text(encoding="utf-8", errors="replace")
                if MARKER + " completed=true" in output:
                    process.stdin.write("quit\n")
                    process.stdin.flush()
                    process.wait(timeout=40)
                    break
                if 'Exception in thread "main"' in output:
                    raise RuntimeError("Native startup failed; inspect " + str(transcript))
                time.sleep(.25)
            else:
                raise RuntimeError("Native API probe did not complete; inspect " + str(transcript))
        finally:
            if process.poll() is None:
                process.terminate()
                process.wait(timeout=15)
    output = transcript.read_text(encoding="utf-8", errors="replace")
    if "Shutdown handling finished" not in output:
        raise RuntimeError("Missing clean shutdown")
    lines = [line[line.index(MARKER):] for line in output.splitlines() if MARKER in line]
    with (GAME / "projectzomboid.jar").open("rb") as stream:
        digest = hashlib.file_digest(stream, "sha256").hexdigest()
    result = {
        "seconds": round(time.monotonic() - started, 1),
        "gameJarSha256": digest,
        "runtimeReports": lines,
        "scope": "Lua API exposure only; no vehicles inserted and no physical/rendered/connected tether test",
    }
    write(OUTPUT / "result.json", json.dumps(result, indent=2) + "\n")
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
