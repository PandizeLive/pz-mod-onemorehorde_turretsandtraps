"""Reproduce C509 findings against one frozen C508 module at a time; never edits Source."""
import hashlib
import json
import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
BASELINE = "2c16cd4"
OUTPUT = ROOT / "diagnostics/c509"
GAME = Path(os.environ.get("PZ_GAME_DIR", "C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid"))
CASES = [
    ("queue-capacity", "server/OMHTT/Damage.lua", "C509 global in-flight capacity queues admitted damage"),
    ("arc-trigger", "server/OMHTT/ControlCycle.lua", "C509 trigger accepts ammo-free Arc"),
    ("scrapshot-siphon", "server/OMHTT/TurretScrapshot.lua", "C509 late primary Scrapshot pellet retains Siphon eligibility"),
    ("piercing-splash", "server/OMHTT/TurretVolley.lua", "C509 piercing splash uses the confirmed hit's damage"),
    ("receipt-retention", "client/OMHTT/DefenseCombatClient.lua", "C509 receipt retention must not lose ordinary sustained contact damage"),
]


def main():
    OUTPUT.mkdir(parents=True, exist_ok=True)
    subprocess.run(["C:/Program Files/Java/jdk-17/bin/javac.exe", "-d", str(OUTPUT),
                    str(ROOT / "tools/KahluaCheck.java")], check=True)
    results = []
    for name, relative, marker in CASES:
        path = "Source/42.20/media/lua/" + relative
        overlay = OUTPUT / "regressions" / name
        target = overlay / path
        target.parent.mkdir(parents=True, exist_ok=True)
        original = subprocess.run(["git", "-c", "safe.directory=" + ROOT.as_posix(), "show", BASELINE + ":" + path],
                                  cwd=ROOT, capture_output=True, check=True).stdout
        target.write_bytes(original)
        env = {**os.environ, "OMHTT_TEST_SOURCE_OVERRIDE": overlay.relative_to(ROOT).as_posix(),
               "OMHTT_TEST_OUTPUT": overlay.relative_to(ROOT).as_posix()}
        command = [str(GAME / "jre64/bin/java.exe"), "--enable-native-access=ALL-UNNAMED", "-Djava.awt.headless=true",
                   "-Duser.home=" + str(overlay / "native-home"), "-cp", os.pathsep.join(map(str, [OUTPUT, GAME / "projectzomboid.jar", GAME])),
                   "KahluaCheck", str(ROOT)]
        result = subprocess.run(command, cwd=ROOT, env=env, capture_output=True, text=True, encoding="utf-8", errors="replace")
        output = result.stdout + result.stderr
        log = overlay / "expected-failure.log"
        log.write_text(output, encoding="utf-8")
        assert result.returncode != 0 and marker in output, f"Unexpected baseline result for {name}: {log}"
        results.append({"finding": name, "baseline": BASELINE, "module": path, "assertion": marker,
                        "expectedFailureReproduced": True, "log": log.relative_to(ROOT).as_posix(),
                        "logSha256": hashlib.sha256(log.read_bytes()).hexdigest()})
        print(f"REPRODUCED {name}: frozen C508 fails the new assertion")
    (OUTPUT / "regressions.json").write_text(json.dumps(results, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
