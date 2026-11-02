"""Apply the C550 prototype in diagnostics and compare it against the tagged combat source."""
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess

import check_mixed_base_c549 as mixed

ROOT = mixed.ROOT
OUT = ROOT / "diagnostics/c550"
PATCH = ROOT / "tools/prototypes/c550-receipts.patch"
BASE = "654349c05ac47cb95a23baad24a520b01b080b90"


def prepare():
    mixed.OUT = OUT
    overlay = OUT / "replay"
    git = ["git", "-c", "safe.directory=" + ROOT.as_posix(), "-C", str(ROOT)]
    paths = re.findall(r"^--- a/(Source/42\.20/media/lua/[^\n]+\.lua)$", PATCH.read_text(encoding="utf-8"), re.M)
    if len(set(paths)) != 6:
        raise ValueError("Expected the six prototype combat files")
    if subprocess.run([*git, "diff", "--quiet", BASE, "--", "Source"], check=False).returncode:
        raise ValueError("Run this comparison with the 0.2.71.10 baseline Source tree")
    for rel in paths:
        target = overlay / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(subprocess.check_output([*git, "show", f"{BASE}:{rel}"]))
    subprocess.run([*git, "apply", "--directory=" + overlay.relative_to(ROOT).as_posix(), PATCH], check=True)
    subprocess.run(["C:/Program Files/Java/jdk-17/bin/javac.exe", "-d", OUT, ROOT / "tools/KahluaCheck.java"], check=True)
    return overlay


def probe(overlay, name, fixture):
    log = OUT / (name + ".log")
    env = {**os.environ, "OMHTT_TEST_OUTPUT": str(OUT), "OMHTT_TEST_SOURCE_OVERRIDE": str(overlay)}
    with log.open("w", encoding="utf-8") as stream:
        result = subprocess.run([mixed.GAME / "jre64/bin/java.exe", "--enable-native-access=ALL-UNNAMED",
                                 "-Djava.awt.headless=true", "-Duser.home=" + str(OUT / "native-home"),
                                 "-cp", os.pathsep.join(map(str, (OUT, mixed.GAME / "projectzomboid.jar", mixed.GAME))),
                                 "KahluaCheck", ROOT, fixture], cwd=ROOT, env=env, stdout=stream, stderr=subprocess.STDOUT)
    output = log.read_text(encoding="utf-8", errors="replace")
    if result.returncode:
        raise RuntimeError(output[-1900:])
    return output


def main():
    overlay = prepare()
    focused = probe(overlay, "focused", "tools/tests/paired_receipts_c550.lua")
    rotary = probe(overlay, "rotary", "tools/tests/rotary_crowd_c547.lua")
    measurements = rotary.split("Optional audit: C547\n")[1].split("\nEND C547")[0].splitlines()
    eight = next(row.split("|") for row in measurements if row.startswith("wire|8|"))
    if eight[2:7] != ["3424", "3424", "3424", "0", "0"]:
        raise RuntimeError("Eight-rotary regression: " + str(eight[:7]))
    evidence = {"baseline": BASE, "candidatePatchSHA256": hashlib.sha256(PATCH.read_bytes()).hexdigest(),
                "connectedPlayers": 0, "focused": re.search(r"C550 focused checks \d+ PASS", focused)[0],
                "focusedSuiteAssertions": int(float(focused.split("Assertions passed: ")[1].splitlines()[0])),
                "rotaryRegressionRows": measurements, "runs": []}
    for repeat in range(1, 4):
        for leg in (150, 50):
            for variant in (("candidate", "stock") if repeat % 2 else ("stock", "candidate")):
                row = mixed.run(leg, variant, repeat, str(overlay), wire_codec=True)
                if (variant == "candidate") != (row["pairedPackets"] > 0):
                    raise RuntimeError("Unexpected receipt path")
                row["requested"] = sum(f["requested"] for f in row["families"].values())
                row["applied"] = sum(f["applied"] for f in row["families"].values())
                if row["requested"] - row["applied"] != sum(row["failures"].values()):
                    raise ValueError("Unaccounted damage request")
                evidence["runs"].append(row)
                (OUT / "final.json").write_text(json.dumps(evidence, indent=2)+"\n", encoding="utf-8")


if __name__ == "__main__":
    main()
