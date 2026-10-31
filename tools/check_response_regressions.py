"""C517 negative controls: frozen production paths must fail the new behavior checks."""
import hashlib
import json
import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "diagnostics/c517"
GAME = Path(os.environ.get("PZ_GAME_DIR", "C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid"))
BASE = "f0b8702"
CASES = {
    "fresh-membership": (["server/DefenseContactServer"], "C517 spatial membership consumes"),
    "first-laser": (["server/ControlSensor"], "C517 first reported laser contact"),
    "late-trap-view": (["client/ControlDiscovery", "client/BedPlayer"], "C517 delayed wire metadata"),
    "continuous-dart": (["shared/TetherCycle"], "C517 outbound dart continues"),
    "attached-dart": (["client/TetherView"], "C517 embedded nail follows"),
    "flight-transit": (["client/PrototypeEffects"], "C517 projectile travel accounts"),
    "visible-aim": (["client/TurretRenderer"], "C517 actual renderer follows"),
    "trigger-expiry": (["server/ControlWorld"], "C517 expired owner report"),
}


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    subprocess.run(["C:/Program Files/Java/jdk-17/bin/javac.exe", "-d", str(OUT),
                    str(ROOT / "tools/KahluaCheck.java")], check=True)
    command = [str(GAME / "jre64/bin/java.exe"), "--enable-native-access=ALL-UNNAMED", "-Djava.awt.headless=true",
               "-Duser.home=" + str(OUT / "native-home"), "-cp", os.pathsep.join(map(str, [OUT, GAME / "projectzomboid.jar", GAME])),
               "KahluaCheck", str(ROOT), "tools/tests/module_pack_audit.lua"]
    evidence = {"baseline": BASE, "connectedClients": 0, "cases": []}
    for name, (modules, expected) in CASES.items():
        overlay = OUT / "pre-fix" / name
        files = []
        for module in modules:
            side, stem = module.split("/")
            relative = f"Source/42.20/media/lua/{side}/OMHTT/{stem}.lua"
            before = subprocess.run(["git", "-c", "safe.directory=" + ROOT.as_posix(), "show", BASE + ":" + relative],
                                    cwd=ROOT, check=True, capture_output=True).stdout
            target = overlay / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(before)
            files.append({"path": relative, "beforeSHA256": hashlib.sha256(before).hexdigest(),
                          "afterSHA256": hashlib.sha256((ROOT / relative).read_bytes()).hexdigest()})
        result = subprocess.run(command, cwd=ROOT, capture_output=True, text=True, encoding="utf-8", errors="replace",
                                env={**os.environ, "OMHTT_TEST_SOURCE_OVERRIDE": str(overlay),
                                     "OMHTT_TEST_OUTPUT": str(OUT / "negative")})
        output = result.stdout + result.stderr
        (OUT / ("before-" + name + ".log")).write_text(output, encoding="utf-8")
        if result.returncode == 0 or expected not in output:
            raise RuntimeError(f"{name}: negative control did not fail at expected behavior: {output[-2200:]}")
        evidence["cases"].append({"case": name, "expectedFailure": expected, "reproduced": True, "files": files})
        print(name + ": original production path failed the expected behavior check", flush=True)
    result = subprocess.run(command, cwd=ROOT, capture_output=True, text=True, encoding="utf-8", errors="replace",
                            env={**os.environ, "OMHTT_TEST_SOURCE_OVERRIDE": "", "OMHTT_TEST_OUTPUT": str(OUT)})
    output = result.stdout + result.stderr
    (OUT / "corrected-suite.log").write_text(output, encoding="utf-8")
    if result.returncode:
        raise RuntimeError(output[-3000:])
    evidence["correctedPassed"] = True
    evidence["result"] = next(line for line in output.splitlines() if line.startswith("Assertions passed:"))
    (OUT / "response-regressions.json").write_text(json.dumps(evidence, indent=2) + "\n", encoding="utf-8")
    print(evidence["result"])


if __name__ == "__main__":
    main()
