"""Exercise production turret services on an isolated stock dedicated server, without clients."""
import os
from pathlib import Path
import shutil
import subprocess
import time

ROOT = Path(__file__).resolve().parents[1]
GAME = Path(os.environ.get("PZ_GAME_DIR", "C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid"))
OUTPUT = ROOT / "diagnostics/c241-multiplayer/authority-server"


def main():
    from build_packages import build
    build(check=True)
    cache = OUTPUT / "cache"
    identifier = "OneMoreHorde_Turrets"
    destination = cache / "mods" / identifier
    shutil.copytree(ROOT / "Contents/mods" / identifier, destination, dirs_exist_ok=True)
    lua = destination / "42.20/media/lua/server"
    (lua / "OMHTT/NativeTurretAuthority.lua").write_text(
        (ROOT / "tools/tests/native_turret_authority.lua").read_text(encoding="utf-8"), encoding="utf-8")
    (lua / "OMHTT_AuthorityProbe.lua").write_text(
        'Events.OnServerStarted.Add(function()\n'
        '    require("OMHTT/NativeTurretAuthority")(IsoPlayer.new(getCell()))\n'
        'end)\n', encoding="utf-8")
    settings = cache / "Server/OMHTT_Authority.ini"
    settings.parent.mkdir(parents=True, exist_ok=True)
    settings.write_text("Mods=OneMoreHorde_Turrets\nPublic=false\nPauseEmpty=true\nUPnP=false\nMap=Muldraugh, KY\nDefaultPort=29163\nUDPPort=29164\n", encoding="utf-8")
    transcript = OUTPUT / "server.log"
    command = [str(GAME / "jre64/bin/java.exe"), "--enable-native-access=ALL-UNNAMED",
               "--add-exports=java.base/jdk.internal.misc=ALL-UNNAMED", "-XX:-CreateCoredumpOnCrash", "-Xmx1536m",
               "-Djava.library.path=./natives/;./natives/win64/;./", "-cp", "projectzomboid.jar;.",
               "zombie.network.GameServer", "-cachedir=" + str(cache), "-servername", "OMHTT_Authority",
               "-nosteam", "-ip", "127.0.0.1", "-port", "29163", "-adminusername", "probe", "-adminpassword", "local-probe"]
    marker = "[OMHTT-Smoke] native-server-turret deploy=exact"
    with transcript.open("w", encoding="utf-8") as output:
        process = subprocess.Popen(command, cwd=GAME, stdin=subprocess.PIPE, stdout=output,
                                   stderr=subprocess.STDOUT, text=True, creationflags=subprocess.CREATE_NO_WINDOW)
        started = time.monotonic()
        passed = False
        try:
            while process.poll() is None and time.monotonic() - started < 240:
                content = transcript.read_text(encoding="utf-8", errors="replace")
                if marker in content:
                    passed = True
                    break
                if "NativeTurretAuthority.lua:" in content or "Exception in thread" in content or "Server Terminated." in content:
                    break
                time.sleep(.5)
            if process.poll() is None:
                process.stdin.write("quit\n")
                process.stdin.flush()
                try:
                    process.wait(timeout=30)
                except subprocess.TimeoutExpired:
                    process.terminate()
                    process.wait(timeout=15)
        finally:
            if process.poll() is None:
                process.terminate()
                process.wait(timeout=15)
        assert passed, f"Native turret authority probe failed; inspect {transcript}"
    print("Stock dedicated-server turret authority/services passed; no player clients connected.")
    print(transcript)


if __name__ == "__main__":
    main()
