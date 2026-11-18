"""Compare the C555 queue prototype with the packaged .11 source in the game's Kahlua runtime."""
import argparse
import hashlib
import json
import subprocess
from pathlib import Path

import check_mixed_base_c549 as mixed
import check_paired_receipts_c550 as paired

ROOT = mixed.ROOT
OUT = ROOT / "diagnostics/c555"
PATCH = ROOT / "tools/prototypes/c555-ack-dispatch.patch"
BASE = "b3a1efe728111d44416396533cae12408c00af6f"


def prepare():
    git = ["git", "-c", "safe.directory=" + ROOT.as_posix(), "-C", str(ROOT)]
    subprocess.run([*git, "diff", "--quiet", BASE, "--", "Source"], check=True)
    overlay = OUT / "replay"
    for name in ("Damage", "DefenseCombatServer"):
        rel = Path(f"Source/42.20/media/lua/server/OMHTT/{name}.lua")
        target = overlay / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(subprocess.check_output([*git, "show", f"{BASE}:{rel.as_posix()}"]))
    subprocess.run([*git, "apply", "--directory=" + overlay.relative_to(ROOT).as_posix(), PATCH], check=True)
    return str(overlay)


def focused(overlay, variants):
    checks = {}
    for variant in variants:
        scene = OUT / "focused.lua"
        scene.write_text("receiptDispatchCandidate=" + str(variant != "stock").lower() + "\n" +
                         (ROOT / "tools/tests/paired_receipts_c550.lua").read_text(encoding="utf-8") +
                         '\ntestPackAudit=testPackAudit.." C555 "..receiptDispatchTrace\n', encoding="utf-8")
        result = paired.probe(overlay if variant == "candidate" else None, variant + "-focused", scene)
        checks[variant] = result.split("Optional audit: ")[1].splitlines()[0]
        print(variant, checks[variant], flush=True)
    return checks


def fixed_control(probe, overlay):
    # Hold the worker clock still within each tick to separate variable work admission
    # from actual downstream contact delivery. Wall-time performance is measured separately.
    mixed.PROBE = OUT / "fixed-control.lua"
    mixed.PROBE.write_text("stressFixedBudget=true\nstressRecordCoverage=true\n" + probe, encoding="utf-8")
    return [mixed.run(150, variant, "fixed", overlay, wire_codec=True) for variant in ("stock", "candidate")]


def main():
    global OUT
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repeat", type=int, default=3)
    parser.add_argument("--release", action="store_true", help="Verify the promoted queue directly from release Source")
    args = parser.parse_args()
    if args.repeat < 1:
        parser.error("repeat must be positive")
    variants = ("stock", "candidate")
    if args.release:
        version = next(line.split("=", 1)[1] for line in (ROOT / "Source/42.20/mod.info").read_text().splitlines()
                       if line.startswith("modversion="))
        OUT = ROOT / "diagnostics" / ("v" + version) / "receipt-dispatch"
        OUT.mkdir(parents=True, exist_ok=True)
        overlay = None
        variants = ("release",)
    else:
        overlay = prepare()
    subprocess.run(["C:/Program Files/Java/jdk-17/bin/javac.exe", "-d", OUT, ROOT / "tools/KahluaCheck.java"], check=True)
    paired.OUT = mixed.OUT = OUT
    report = {"base": BASE, "patchSHA256": hashlib.sha256(PATCH.read_bytes()).hexdigest(), "connectedPlayers": 0,
              "focused": focused(overlay, variants), "runs": []}
    rotary = paired.probe(overlay, variants[-1] + "-eight-rotary", "tools/tests/rotary_crowd_c547.lua")
    eight = next(row for row in rotary.splitlines() if row.startswith("wire|8|"))
    if eight.split("|")[2:7] != ["3424", "3424", "3424", "0", "0"]:
        raise RuntimeError("Eight-rotary regression: " + eight)
    report["eightRotary"] = eight
    probe = mixed.PROBE.read_text(encoding="utf-8")
    for repeat in range(1, args.repeat + 1):
        for leg in ((50, 155) if args.release else (50, 150, 55, 155)):
            phased = leg in (55, 155)
            mixed.PROBE = OUT / "mixed.lua"
            mixed.PROBE.write_text("stressRecordCoverage=true\nstressBetweenTicks=" + str(phased).lower() + "\n" + probe,
                                   encoding="utf-8")
            for variant in (variants if repeat % 2 else reversed(variants)):
                row = mixed.run(leg, variant, repeat, overlay, wire_codec=True)
                row["betweenTicks"] = phased
                report["runs"].append(row)
                (OUT / "results.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    report["fixedControl"] = [] if args.release else fixed_control(probe, overlay)
    (OUT / "results.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    incomplete = [r for r in report["runs"] + report["fixedControl"] if r.get("incompleteCoverage")]
    if incomplete:
        raise RuntimeError(f"{len(incomplete)} mixed scenes have incomplete coverage. Inspect results.json.")


if __name__ == "__main__":
    main()
