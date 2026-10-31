"""Record source-only C509 evidence after checks; require an exact native cache match."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess

from build_packages import expected_files, IDS

ROOT = Path(__file__).resolve().parents[1]


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("native_log", type=Path)
    args = parser.parse_args()
    native_log = args.native_log.resolve()
    native_log.relative_to(ROOT / "diagnostics")
    subprocess.run(["git", "-c", "safe.directory=" + ROOT.as_posix(), "diff", "--exit-code", "--",
                    "Contents", "WORKSHOP_CHANGELOG.txt", "Source/42.20/mod.info"], cwd=ROOT, capture_output=True, check=True)
    version, expected = expected_files()
    verified = {}
    for component, files in expected.items():
        for relative, data in files.items():
            candidate = native_log.parent / "cache/mods" / IDS[component] / relative
            assert candidate.read_bytes() == data, (component, relative)
        verified[component] = len(files)
    native = native_log.read_text(encoding="utf-8", errors="replace")
    assert "[OMHTT-C509] native-catalog heads=10 modules=36 cells=360 compatible=329" in native
    assert "bed=landing-once wire=repeat tack=repeat overlap=single martyrdom=root-and-synergy clients=0" in native
    assert not any("MOD:OMH:" in line and "Exception thrown" in line for line in native.splitlines())
    output = ROOT / "diagnostics/c509"
    full = (output / "full-suite.log").read_text(encoding="utf-8")
    assert "C509 coverage: heads=10 catalogCells=360 singleModuleHitCases=339" in full
    regressions = json.loads((output / "regressions.json").read_text(encoding="utf-8"))
    assert len(regressions) == 5 and all(row["expectedFailureReproduced"] for row in regressions)
    for row in regressions:
        assert digest(ROOT / row["log"]) == row["logSha256"]
    evidence_dir = ROOT / "docs/evidence"
    matrix = output / "multiplayer-matrix-c509.tsv"
    (evidence_dir / "c509-hit-matrix.tsv").write_bytes(matrix.read_bytes())
    evidence = {
        "checkpoint": "C509", "status": "source candidate; packaging held; connected acceptance pending",
        "unchangedPackagedVersion": version, "sourceBaseline": "2c16cd4",
        "assertions": int(float(re.search(r"Assertions passed: ([0-9.]+)", full)[1])),
        "protocolFaultAssertions": 189, "headFamilies": 10, "modules": 32, "expansionKits": 4,
        "compatibilityStatCells": 360, "supportedSingleModuleHitCasesPlusBaselines": 339,
        "combinedArcCases": 2, "simultaneousVictims": 129, "sustainedHits": 600, "distinctRecentVictims": 600,
        "proofLimits": ["world/actor/transport doubles in Kahlua replays", "native catalog is not firing proof",
                        "zero connected clients", "no rendered smoothness or internet latency claim",
                        "representative interacting module combinations, not all permutations or third-party guns"],
        "regressions": regressions,
        "native": {"clients": 0, "log": native_log.relative_to(ROOT).as_posix(), "sha256": digest(native_log),
                   "exactCurrentSourceFilesVerified": verified},
        "logs": {p.name: digest(p) for p in sorted(output.glob("*.log"))},
        "matrixSha256": digest(matrix),
        "sourceSha256": {p.relative_to(ROOT).as_posix(): digest(p) for p in sorted((ROOT / "Source").rglob("*")) if p.is_file()},
        "verificationCodeSha256": {p.relative_to(ROOT).as_posix(): digest(p) for p in [
            ROOT / "tools/KahluaCheck.java", ROOT / "tools/check_combat_path.py",
            ROOT / "tools/check_multiplayer_regressions.py", ROOT / "tools/smoke_turret_authority.py",
            ROOT / "tools/tests/multiplayer_matrix_c509.lua", ROOT / "tools/tests/multiplayer_traps_c509.lua",
            ROOT / "tools/tests/native_catalog_c509.lua"]},
        "notPerformed": ["release packaging", "version bump", "install", "Workshop stage/upload", "live-server changes",
                         "sibling edits", "GitHub mirror (prior approval-review block)"]
    }
    (evidence_dir / "c509-verification.json").write_text(json.dumps(evidence, indent=2) + "\n", encoding="utf-8")
    print("C509 evidence recorded; exact native cache files:", verified)


if __name__ == "__main__":
    main()
