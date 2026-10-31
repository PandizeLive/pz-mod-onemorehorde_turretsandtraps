"""Exercise production turret services on an isolated stock dedicated server, without clients."""
import os
from pathlib import Path
import shutil
import subprocess
import time
import argparse

ROOT = Path(__file__).resolve().parents[1]
GAME = Path(os.environ.get("PZ_GAME_DIR", "C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid"))
OUTPUT = ROOT / "diagnostics/c503-contacts" / time.strftime("%Y%m%d-%H%M%S")
IDENTIFIERS = ["OneMoreHorde_Turrets", "OneMoreHorde_Traps"]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", action="store_true", help="Use an isolated source candidate; leave release packages untouched")
    args = parser.parse_args()
    from build_packages import build, expected_files
    candidate = expected_files()[1] if args.source else None
    if not args.source:
        build(check=True)
    cache = OUTPUT / "cache"
    identifier = "OneMoreHorde_Turrets"
    destination = cache / "mods" / identifier
    for selected in IDENTIFIERS:
        if candidate:
            component = "turrets" if selected.endswith("Turrets") else "traps"
            for relative, content in candidate[component].items():
                target = cache / "mods" / selected / relative
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(content)
        else:
            shutil.copytree(ROOT / "Contents/mods" / selected, cache / "mods" / selected, dirs_exist_ok=True)
    lua = destination / "42.20/media/lua/server"
    (lua / "OMHTT/NativeTurretAuthority.lua").write_text(
        (ROOT / "tools/tests/native_turret_authority.lua").read_text(encoding="utf-8"), encoding="utf-8")
    (lua / "OMHTT/NativeTrapServices.lua").write_text(
        (ROOT / "tools/tests/native_trap_services.lua").read_text(encoding="utf-8"), encoding="utf-8")
    (lua / "OMHTT/NativeCombatAuthority.lua").write_text(
        (ROOT / "tools/tests/native_combat_authority.lua").read_text(encoding="utf-8"), encoding="utf-8")
    (lua / "OMHTT/NativeContactsC503.lua").write_text(
        (ROOT / "tools/tests/native_contacts_c503.lua").read_text(encoding="utf-8"), encoding="utf-8")
    (lua / "OMHTT/NativeContactC508.lua").write_text(
        (ROOT / "tools/tests/native_contact_c508.lua").read_text(encoding="utf-8"), encoding="utf-8")
    (lua / "OMHTT/NativeCatalogC509.lua").write_text(
        (ROOT / "tools/tests/native_catalog_c509.lua").read_text(encoding="utf-8"), encoding="utf-8")
    (lua / "OMHTT_AuthorityProbe.lua").write_text(
        'Events.OnServerStarted.Add(function()\n'
        '    require("OMHTT/NativeContactC508")()\n'
        '    require("OMHTT/NativeCatalogC509")()\n'
        '    require("OMHTT/NativeCombatAuthority")()\n'
        '    require("OMHTT/NativeTurretAuthority")(IsoPlayer.new(getCell()))\n'
        '    require("OMHTT/NativeContactsC503")()\n'
        'end)\n', encoding="utf-8")
    settings = cache / "Server/OMHTT_Authority.ini"
    settings.parent.mkdir(parents=True, exist_ok=True)
    settings.write_text("Mods=" + ";".join(IDENTIFIERS) + "\nPublic=false\nPauseEmpty=false\nUPnP=false\nMap=Muldraugh, KY\nDefaultPort=29163\nUDPPort=29164\n", encoding="utf-8")
    transcript = OUTPUT / "server.log"
    command = [str(GAME / "jre64/bin/java.exe"), "--enable-native-access=ALL-UNNAMED",
               "--add-exports=java.base/jdk.internal.misc=ALL-UNNAMED", "-XX:-CreateCoredumpOnCrash", "-Xmx1536m",
               "-Djava.library.path=./natives/;./natives/win64/;./", "-cp", "projectzomboid.jar;.",
               "zombie.network.GameServer", "-cachedir=" + str(cache), "-servername", "OMHTT_Authority",
               "-nosteam", "-ip", "127.0.0.1", "-port", "29163", "-adminusername", "probe", "-adminpassword", "local-probe"]
    marker = "[OMHTT-C503] native-contacts event=OnTick"
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
                if "NativeCatalogC509.lua:" in content or "NativeContactC508.lua:" in content or "NativeContactsC503.lua:" in content or "NativeTurretAuthority.lua:" in content or "NativeCombatAuthority.lua:" in content or "Exception in thread" in content or "Server Terminated." in content:
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
        content = transcript.read_text(encoding="utf-8", errors="replace")
        assert "[OMHTT-C508] native-clock-corpse passed=true" in content, "Native C508 API checks failed"
        assert "[OMHTT-C509] native-catalog heads=10 modules=36 cells=360" in content, "Native C509 catalog checks failed"
        mod_errors = [line for line in content.splitlines() if "MOD:OMH:" in line and "Exception thrown" in line]
        assert not mod_errors, f"Native mod callbacks threw despite completion markers: {mod_errors}; inspect {transcript}"
        assert 'Packet "AddInventoryItemToContainer" send failed' not in content, "Premature corpse inventory synchronization failed"
    print("Stock dedicated-server turret authority/services passed; no player clients connected.")
    print(transcript)


if __name__ == "__main__":
    main()
