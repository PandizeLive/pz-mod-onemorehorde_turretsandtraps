import os
import re
import shutil
import subprocess
import time
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
GAME = Path(os.environ.get("PZ_GAME_DIR", "C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid"))
VERSION = re.search(r"^modversion=(.+)$", (ROOT / "Source/42.20/mod.info").read_text(), re.MULTILINE).group(1).strip()
OUTPUT = ROOT / "diagnostics" / ("vault-prototype" if os.environ.get("OMHTT_VAULT_PROBE") == "1" else "v" + VERSION)
CACHE = OUTPUT / "server-cache"


def main():
    OUTPUT.mkdir(parents=True, exist_ok=True)
    from build_packages import IDS, build
    version, _ = build(check=True)
    for identifier in IDS.values():
        shutil.copytree(ROOT / "Contents/mods" / identifier, CACHE / "mods" / identifier, dirs_exist_ok=True)
    settings = CACHE / "Server/OMHTT_P1C1.ini"
    settings.parent.mkdir(parents=True, exist_ok=True)
    settings.write_text("Mods=OneMoreHorde_Traps;OneMoreHorde_Turrets\nPublic=false\nPauseEmpty=true\nUPnP=false\nMap=Muldraugh, KY\nDefaultPort=29161\nUDPPort=29162\n", encoding="utf-8")
    destination = CACHE / "mods/OneMoreHorde_Traps"
    probe = destination / "42.20/media/lua/server/OMHTT_TranslationSmoke.lua"
    probe.write_text((ROOT / "tools/tests/native_smoke.lua").read_text(encoding="utf-8"), encoding="utf-8")
    bed_probe = destination / "42.20/media/lua/server/OMHTT_BedSmoke.lua"
    bed_probe.write_text((ROOT / "tools/tests/native_beds.lua").read_text(encoding="utf-8"), encoding="utf-8")
    barb_probe = destination / "42.20/media/lua/server/OMHTT_BarbSmoke.lua"
    barb_probe.write_text((ROOT / "tools/tests/native_barbs.lua").read_text(encoding="utf-8"), encoding="utf-8")
    turret_probe = CACHE / "mods/OneMoreHorde_Turrets/42.20/media/lua/server/OMHTT_TurretSmoke.lua"
    turret_probe.write_text((ROOT / "tools/tests/native_turret_smoke.lua").read_text(encoding="utf-8"), encoding="utf-8")
    console = CACHE / "server-console.txt"
    transcript = OUTPUT / ("server-" + os.environ.get("OMHTT_PROBE_MODE", "write") + ".log")
    classes = OUTPUT / "persistence-classes"
    classes.mkdir(exist_ok=True)
    subprocess.run(["C:/Program Files/Java/jdk-17/bin/javac.exe", "-d", str(classes), str(ROOT / "tools/NativePersistenceCheck.java"), str(ROOT / "tools/NativeVaultProbe.java"), str(ROOT / "tools/NativeTurretProbe.java"), str(ROOT / "tools/NativeBarbProbe.java")], check=True)
    command = [str(GAME / "jre64/bin/java.exe"), "--enable-native-access=ALL-UNNAMED",
        "--add-exports=java.base/jdk.internal.misc=ALL-UNNAMED", "-XX:-CreateCoredumpOnCrash", "-Xmx1536m",
        "-Djava.library.path=./natives/;./natives/win64/;./", "-cp", str(classes) + (";projectzomboid.jar;." if os.environ.get("OMHTT_STOCK_CLASSES") == "1" else ";.;projectzomboid.jar"), "NativePersistenceCheck", str(OUTPUT / "native-objects"), os.environ.get("OMHTT_PROBE_MODE", "write"),
        "-cachedir=" + str(CACHE), "-servername", "OMHTT_P1C1", "-nosteam", "-ip", "127.0.0.1", "-port", "29161", "-adminusername", "probe", "-adminpassword", "local-probe"]
    with transcript.open("w", encoding="utf-8") as output:
        process = subprocess.Popen(command, cwd=GAME, stdin=subprocess.PIPE, stdout=output,
            stderr=subprocess.STDOUT, text=True, creationflags=subprocess.CREATE_NO_WINDOW)
        started = time.monotonic()
        try:
            while process.poll() is None and time.monotonic() - started < 150:
                text = transcript.read_text(encoding="utf-8", errors="replace")
                if 'Exception in thread "main"' in text or "Server Terminated." in text:
                    raise RuntimeError(f"Game startup failed before probes; inspect {transcript.name}")
                if "OMHTT_TranslationSmoke.lua:" in text or "OMHTT_TurretSmoke.lua:" in text or "OMHTT_BedSmoke.lua:" in text:
                    process.stdin.write("quit\n")
                    process.stdin.flush()
                    process.wait(timeout=40)
                    raise RuntimeError(f"Native probe failed; inspect {transcript.name}")
                if "*** SERVER STARTED" in text and "[OMHTT-Smoke] native-portable recipe=registered" in text and "[OMHTT-Smoke] native-turret recipes=6" in text:
                    assert "[OMHTT] server-ready version=" + version in text, "Mod did not initialize"
                    assert "[OMHTT-Smoke] native-translations checked=3 missing=0" in text, "Native translations failed smoke probe"
                    assert "[OMHTT-Smoke] native-build-menu registered=1 title=Spike_Barrier category=OMHTraps callback=resolved spGate=hidden disabledGate=closed dottedCallback=rejected" in text, "Native menu callback or enumeration failed smoke probe"
                    assert "[OMHTT-Smoke] native-construction entity=OMHTTSpikeBarrier faces=4 parts=16 inputs=3 translated=true mpGate=closed" in text, "Native construction registration failed smoke probe"
                    assert "[OMHTT-Smoke] native-sprites objects=16 valid=16 categoryTranslated=true" in text, "Native object creation or category translation failed"
                    assert "[OMHTT-Smoke] native-ingredients mixes=75 missingWood=blocked missingBindings=blocked missingTool=blocked dullTool=blocked brokenTool=blocked preview=nonconsuming" in text, "Native ingredient matrix failed smoke probe"
                    process.stdin.write("quit\n")
                    process.stdin.flush()
                    process.wait(timeout=40)
                    break
                time.sleep(0.25)
            else:
                raise RuntimeError(f"Dedicated server failed to reach ready; inspect {transcript.name}")
        finally:
            if process.poll() is None:
                process.terminate()
                process.wait(timeout=15)
            probe.unlink(missing_ok=True)
            bed_probe.unlink(missing_ok=True)
            barb_probe.unlink(missing_ok=True)
            turret_probe.unlink(missing_ok=True)
    text = transcript.read_text(encoding="utf-8", errors="replace")
    assert "[OMHTT-Smoke] native-distance-parity samples=16 passed=true" in text, "Native accuracy parity failed"
    assert "[OMHTT-Smoke] native-atlas-lua bypass=verified restore=verified" in text, "Native atlas exposure failed"
    assert "[OMHTT-Smoke] native-suppression sounds=18 potato=2 reload=native" in text, "Native audio registration failed"
    assert "[OMHTT-Smoke] native-scratch lowerLeg=true knox=false" in text, "Native scratch failed"
    assert "[OMHTT-VaultProbe] native-vision=12/12 object-and-grid=true collision-preserved=true" in text, "Native transparency failed"
    assert "[OMHTT-Smoke] native-reinforced deploy=1 pack=5to1 unpack=1to5 mixed=blocked materials=10 hammer=retained" in text, "Native reinforcement transactions failed"
    assert "[OMHTT-VaultProbe] native-corners=2/2 both-pathfinders=true directional-thump-ownership=true" in text, "Native shared corner recognition failed"
    assert "[OMHTT-VaultProbe] native-state-execute=4/4 native-edge-collision=4/4" in text, "Native vault proof failed"
    assert "[OMHTT-Smoke] native-persistence mode=" + os.environ.get("OMHTT_PROBE_MODE", "write") + " parts=28" in text, "Native object persistence failed"
    assert "native-turret-collision sides=4 player-and-zombie=blocked vision=clear reach=clear firing=clear pathfinders=2" in text, "Turret native collision/access failed"
    assert "Shutdown handling finished" in text, "No clean shutdown evidence"
    assert "Saving GlobalModData" in text, "No native global state save"
    assert "Invalid SpriteConfig object! scripted object = OMHTT" not in text, "Invalid native barrier identity"
    assert "[OMHTT-Smoke] native-sandbox damage=10 maxHealth=100 tooltip=formatted" in text, "Native Sandbox options/tooltip invalid"
    assert "[OMHTT-Smoke] native-texturepacks traps=72 turrets=21 pages=31 png=valid" in text, "Native texture packs invalid"
    assert "[OMHTT-Beds] PASS" in text, "Native bed content invalid"
    assert "[OMHTT-HybridBuild] native-original-recipe=true" in text, "Native hybrid crafting/building proof missing"
    assert "[OMHTT-Beds] controlled-native-recovery forwardLanding=true getUpTransition=passed getUpExit=cleared" in text, "Native forward trip recovery failed"
    assert "[OMHTT-Wire] craft=exact" in text and "[OMHTT-BarbMovement] native-delta=half" in text, "Wire/native displacement proof missing"
    assert "[OMHTT-Barbs] PASS" in text and "[OMHTT-Barbs] persistence mode=" + os.environ.get("OMHTT_PROBE_MODE", "write") in text, "Native barb content/persistence invalid"
    assert "OMHTT_BarbSmoke.lua:" not in text, "Native barb probe raised a Lua/bridge error"
    assert "Lua code called from the wrong thread" not in text, "Native probe used the wrong Lua thread"
    assert "[OMHTT-Beds] persistence mode=" + os.environ.get("OMHTT_PROBE_MODE", "write") + " parts=32" in text, "Native bed persistence failed"
    assert "[OMHTT-Smoke] native-module-loot-parser pools=16 items=121 weights=positive" in text, "Native module loot parse failed"
    assert "[OMHTT-Smoke] native-modules loot=121 profiles=valid condition=checked" in text, "Native module rules failed"
    assert "[OMHTT-Smoke] native-install exact=selected decoy=preserved preview=nonconsuming" in text, "Native Install selection failed"
    assert "[OMHTT-Smoke] native-turret-persistence mode=" + os.environ.get("OMHTT_PROBE_MODE", "write") in text, "Turret world persistence failed"
    assert "[OMHTT-Smoke] native-improvised mode=" + os.environ.get("OMHTT_PROBE_MODE", "write") in text, "Improvised exact-item persistence failed"
    assert "[OMHTT-Smoke] native-packed-turret mode=" + os.environ.get("OMHTT_PROBE_MODE", "write") in text, "Turret portable persistence failed"
    assert "[OMHTT-Smoke] native-firearms firearms=20 rounds=conserved models=bound reload=timed" in text, "Native firearm adapters failed"
    assert "[OMHTT-Smoke] native-magazines insert=eject=conserved chamber=retained replay=blocked capacity=checked mount=bound" in text, "Native magazine transaction failed"
    assert "[OMHTT-Smoke] native-firearm-persistence mode=" + os.environ.get("OMHTT_PROBE_MODE", "write") in text, "Native firearm persistence failed"
    assert "[OMHTT-Smoke] native-hybrid-persistence mode=" + os.environ.get("OMHTT_PROBE_MODE", "write") in text, "Hybrid probe persistence failed"
    assert "[OMHTT-Smoke] native-migration staleSprite=repaired" in text, "Native migration failed"
    assert "[OMHTT-Smoke] native-bundles packed=5to1 unpacked=1to5 weight=6.6 xp=0 insufficient=blocked" in text, "Native bundle transactions failed"
    assert "NoSuchFileException" not in text, "Missing package directories"
    assert "Recipe OMHTTSpikeBarrier missing UiConfigScript" not in text, "Missing native menu UI configuration"
    shutil.copy2(console, OUTPUT / ("server-" + os.environ.get("OMHTT_PROBE_MODE", "write") + "-console.log"))
    for line in text.splitlines():
        if any(token in line for token in ["version=42", "loading OneMoreHorde_", "[OMHTT]", "[OMHTT-Smoke]", "SERVER STARTED", "Saving GlobalModData", "Shutdown handling finished"]):
            print(line)
    print(f"Dedicated startup/restart/save/shutdown smoke passed in {time.monotonic() - started:.1f}s; no player connected.")


if __name__ == "__main__":
    main()
