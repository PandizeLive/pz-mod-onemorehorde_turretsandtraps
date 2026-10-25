"""Load coordinated release packages and prove offline ledger persistence on stock B42."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import time

ROOT = Path(__file__).resolve().parents[1]
GAME = Path(os.environ.get("PZ_GAME_DIR", "C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid"))
OUTPUT = ROOT / "diagnostics/v0.2.68/xp-release"


def main():
    # A fresh cache per invocation; never touch owner saves or an earlier probe.
    cache = OUTPUT / ("cache-" + time.strftime("%Y%m%d-%H%M%S"))
    packages = [(ROOT, "OneMoreHorde_Traps"), (ROOT, "OneMoreHorde_Turrets"),
                (ROOT.parent / "Trait Shop", "OneMoreHorde_TraitShop"),
                (ROOT.parent / "pz-mod-onemorehorde_protectthecure", "OneMoreHorde_HordeNight")]
    for project, name in packages:
        shutil.copytree(project / "Contents/mods" / name, cache / "mods" / name)
    settings = cache / "Server/OMHTT_XPRelease.ini"
    settings.parent.mkdir(parents=True, exist_ok=True)
    settings.write_text("Mods=" + ";".join(name for _, name in packages) +
        "\nPublic=false\nPauseEmpty=true\nUPnP=false\nMap=Muldraugh, KY\nDefaultPort=29361\nUDPPort=29362\n", encoding="utf-8")
    probe = cache / "mods/OneMoreHorde_Turrets/42.20/media/lua/server/XPRelease.lua"
    reports = []
    for mode in ("write", "read"):
        probe.write_text((ROOT / "tools/tests/native_xp_release.lua").read_text(encoding="utf-8").replace(
            "EXPECT_READ", "true" if mode == "read" else "false"), encoding="utf-8")
        log = OUTPUT / (mode + ".log")
        command = [str(GAME / "jre64/bin/java.exe"), "--enable-native-access=ALL-UNNAMED",
            "--add-exports=java.base/jdk.internal.misc=ALL-UNNAMED", "-XX:-CreateCoredumpOnCrash", "-Xmx1536m",
            "-Djava.library.path=./natives/;./natives/win64/;./", "-cp", "projectzomboid.jar", "zombie.network.GameServer",
            "-cachedir=" + str(cache), "-servername", "OMHTT_XPRelease", "-nosteam", "-ip", "127.0.0.1",
            "-port", "29361", "-adminusername", "probe", "-adminpassword", "local-probe"]
        with log.open("w", encoding="utf-8") as stream:
            process = subprocess.Popen(command, cwd=GAME, stdin=subprocess.PIPE, stdout=stream, stderr=subprocess.STDOUT,
                text=True, creationflags=subprocess.CREATE_NO_WINDOW)
            start = time.monotonic()
            try:
                while process.poll() is None and time.monotonic() - start < 160:
                    text = log.read_text(encoding="utf-8", errors="replace")
                    if "[OMHTT-XPRelease] PASS mode=" + mode in text:
                        process.stdin.write("quit\n")
                        process.stdin.flush()
                        process.wait(timeout=40)
                        break
                    if "XPRelease.lua:" in text or 'Exception in thread "main"' in text:
                        raise RuntimeError("Coordinated native probe failed: " + str(log))
                    time.sleep(.25)
                else:
                    raise RuntimeError("Coordinated native probe timed out: " + str(log))
            finally:
                if process.poll() is None:
                    process.terminate()
                    process.wait(timeout=15)
        text = log.read_text(encoding="utf-8", errors="replace")
        assert "Shutdown handling finished" in text, "Native save/shutdown did not finish"
        reports.append({"mode": mode, "seconds": round(time.monotonic()-start, 1), "passed": True})
    result = {"reports": reports, "scope": "Stock zero-client server startup and saved ledger across fresh processes; connected transport remains pending."}
    (OUTPUT / "result.json").write_text(json.dumps(result, indent=2), encoding="utf-8")
    print(json.dumps(result))


if __name__ == "__main__":
    main()
