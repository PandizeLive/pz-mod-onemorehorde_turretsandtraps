import os
import re
import shutil
import subprocess
import time
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
GAME = Path(os.environ.get("PZ_GAME_DIR", "C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid"))
VERSION = re.search(r"^modversion=(.+)$", (ROOT / "Contents/mods/OneMoreHorde_TurretsAndTraps/42.20/mod.info").read_text(), re.MULTILINE).group(1).strip()
OUTPUT = ROOT / "diagnostics" / ("v" + VERSION)
CACHE = ROOT / "diagnostics/p1c1/server-cache"


def main():
    OUTPUT.mkdir(parents=True, exist_ok=True)
    source = ROOT / "Contents/mods/OneMoreHorde_TurretsAndTraps"
    version = re.search(r"^modversion=(.+)$", (source / "42.20/mod.info").read_text(), re.MULTILINE).group(1).strip()
    destination = CACHE / "mods/OneMoreHorde_TurretsAndTraps"
    shutil.copytree(source, destination, dirs_exist_ok=True)
    probe = destination / "42.20/media/lua/server/OMHTT_TranslationSmoke.lua"
    probe.write_text((ROOT / "tools/tests/native_smoke.lua").read_text(encoding="utf-8"), encoding="utf-8")
    console = CACHE / "server-console.txt"
    transcript = OUTPUT / ("server-" + os.environ.get("OMHTT_PROBE_MODE", "write") + ".log")
    classes = OUTPUT / "persistence-classes"
    classes.mkdir(exist_ok=True)
    subprocess.run(["C:/Program Files/Java/jdk-17/bin/javac.exe", "-d", str(classes), str(ROOT / "tools/NativePersistenceCheck.java")], check=True)
    command = [str(GAME / "jre64/bin/java.exe"), "--enable-native-access=ALL-UNNAMED",
        "--add-exports=java.base/jdk.internal.misc=ALL-UNNAMED", "-XX:-CreateCoredumpOnCrash", "-Xmx1536m",
        "-Djava.library.path=./natives/;./natives/win64/;./", "-cp", str(classes) + ";.;projectzomboid.jar", "NativePersistenceCheck", str(OUTPUT / "native-objects"), os.environ.get("OMHTT_PROBE_MODE", "write"),
        "-cachedir=" + str(CACHE), "-servername", "OMHTT_P1C1", "-nosteam", "-ip", "127.0.0.1", "-port", "29161"]
    with transcript.open("w", encoding="utf-8") as output:
        process = subprocess.Popen(command, cwd=GAME, stdin=subprocess.PIPE, stdout=output,
            stderr=subprocess.STDOUT, text=True, creationflags=subprocess.CREATE_NO_WINDOW)
        started = time.monotonic()
        try:
            while process.poll() is None and time.monotonic() - started < 150:
                text = transcript.read_text(encoding="utf-8", errors="replace")
                if "OMHTT_TranslationSmoke.lua:" in text:
                    process.stdin.write("quit\n")
                    process.stdin.flush()
                    process.wait(timeout=40)
                    raise RuntimeError(f"Native probe failed; inspect {transcript.name}")
                if "*** SERVER STARTED" in text and "[OMHTT-Smoke] native-portable recipe=registered" in text:
                    assert "[OMHTT] server-ready version=" + version in text, "Mod did not initialize"
                    assert "[OMHTT-Smoke] native-translations checked=3 missing=0" in text, "Native translations failed smoke probe"
                    assert "[OMHTT-Smoke] native-build-menu registered=1 title=Spike_Barrier category=Carpentry callback=resolved spGate=open disabledGate=closed dottedCallback=rejected" in text, "Native menu callback or enumeration failed smoke probe"
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
    text = transcript.read_text(encoding="utf-8", errors="replace")
    assert "[OMHTT-Smoke] native-persistence mode=" + os.environ.get("OMHTT_PROBE_MODE", "write") + " parts=16" in text, "Native object persistence failed"
    assert "Shutdown handling finished" in text, "No clean shutdown evidence"
    assert "Saving GlobalModData" in text, "No native global state save"
    assert "Invalid SpriteConfig object! scripted object = OMHTT" not in text, "Invalid native barrier identity"
    assert "[OMHTT-Smoke] native-texturepack entries=16 pages=4 png=valid" in text, "Native texture pack invalid"
    assert "[OMHTT-Smoke] native-migration staleSprite=repaired" in text, "Native migration failed"
    assert "NoSuchFileException" not in text, "Missing package directories"
    assert "Recipe OMHTTSpikeBarrier missing UiConfigScript" not in text, "Missing native menu UI configuration"
    shutil.copy2(console, OUTPUT / ("server-" + os.environ.get("OMHTT_PROBE_MODE", "write") + "-console.log"))
    for line in text.splitlines():
        if any(token in line for token in ["version=42", "loading OneMoreHorde_TurretsAndTraps", "[OMHTT]", "[OMHTT-Smoke]", "SERVER STARTED", "Saving GlobalModData", "Shutdown handling finished"]):
            print(line)
    print(f"Dedicated startup/restart/save/shutdown smoke passed in {time.monotonic() - started:.1f}s; no player connected.")


if __name__ == "__main__":
    main()
