"""Replay the local 100-zombie mixed defense scene using the installed Kahlua runtime."""
import argparse
import json
import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "diagnostics/c549"
GAME = Path(os.environ.get("PZ_GAME_DIR", "C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid"))
PROBE = ROOT / "tools/tests/mixed_base_c549.lua"
BARRIER = Path("Source/42.20/media/lua/server/OMHTT/BarrierRetaliation.lua")


def comparison_overlay():
    source = (ROOT / BARRIER).read_text(encoding="utf-8")
    start = source.index("    local zombie, scanned = nil, 0")
    stop = source.index("    if not zombie or zombie:isDead()", start)
    fallback = source[start:stop].replace("local zombie, scanned = nil, 0", "local scanned = 0")
    fast = """    local zombie = Actors.online[message.id]
    local indexedSquare = zombie and Actors.square(zombie)
    if not indexedSquare or zombie:getOnlineID() ~= message.id or not instanceof(zombie, "IsoZombie")
        or indexedSquare:getZ() ~= message.z or math.abs(indexedSquare:getX()-message.x) > 2
        or math.abs(indexedSquare:getY()-message.y) > 2
        or require("OMHTT/DefenseCombatProtocol").outfit(zombie:getPersistentOutfitID()) ~= message.outfit
        or zombie:getOwnerPlayer() ~= player then
        zombie = nil
"""
    overlay = OUT / "lookup-only"
    target = overlay / BARRIER
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(source[:start] + fast + "".join("    " + line for line in fallback.splitlines(True)) +
                      "    end\n" + source[stop:], encoding="utf-8")
    return str(overlay)


def receipt_model(events, leg, limit):
    """One in-flight receipt per victim. A new hit dispatches immediately on an idle lane."""
    victims = {}
    for event in events:
        victim, arrival, deadline = map(int, event.split(","))
        victims.setdefault(victim, []).append((arrival, deadline))
    delays, expired, groups = [], 0, 0
    for hits in victims.values():
        index, ready = 0, 0
        while index < len(hits):
            dispatch = max(ready, hits[index][0])
            count = 0
            while index < len(hits) and hits[index][0] <= dispatch and count < limit:
                arrival, deadline = hits[index]
                index += 1
                if dispatch + leg > deadline:
                    expired += 1
                else:
                    delays.append(dispatch + leg - arrival)
                    count += 1
                # The first idle arrival leaves immediately. Later arrivals can join after its receipt.
                if count and dispatch > ready:
                    break
            ready = dispatch + 2 * leg if count else dispatch
            groups += int(count > 0)
    delays.sort()
    return {"applied": len(delays), "expired": expired, "receipts": groups,
            "ownerP95Ms": delays[(len(delays)*95+99)//100-1]}


def run(leg, variant, repeat, overlay, trace=False):
    audit = OUT / f"scene-{leg}.lua"
    audit.write_text(f"stressLeg={leg}\nstressTrace={str(trace).lower()}\n" + PROBE.read_text(encoding="utf-8"), encoding="utf-8")
    label = f"{variant}-{leg}-{repeat}"
    log = OUT / (label + ".log")
    env = {**os.environ, "OMHTT_TEST_OUTPUT": str(OUT)}
    env.pop("OMHTT_TEST_SOURCE_OVERRIDE", None)
    if variant == "index":
        env["OMHTT_TEST_SOURCE_OVERRIDE"] = overlay
    with log.open("w", encoding="utf-8") as stream:
        p = subprocess.run([GAME / "jre64/bin/java.exe", "--enable-native-access=ALL-UNNAMED",
                            "-Djava.awt.headless=true", "-Duser.home=" + str(OUT / "native-home"),
                            "-cp", os.pathsep.join(map(str, (OUT, GAME / "projectzomboid.jar", GAME))),
                            "KahluaCheck", ROOT, audit], cwd=ROOT, env=env, stdout=stream, stderr=subprocess.STDOUT)
    output = log.read_text(encoding="utf-8", errors="replace")
    if p.returncode:
        raise RuntimeError(label + "\n" + "\n".join(output.splitlines()[-14:]))
    lines = output.split("Optional audit: C549\n", 1)[1].split("\nEND C549", 1)[0].splitlines()
    result = {"variant": variant, "oneWayMs": leg, "repeat": repeat, "families": {}, "ms": {}, "failures": {}, "cutoff": {}}
    for line in lines:
        key, *parts = line.split()
        if key == "family":
            result["families"][parts[0]] = dict(zip(
                ("shots","requested","applied","distinctSources","ackP50","ackP95","ownerP95"), map(int, parts[1:]), strict=True))
        elif key == "ms":
            result["ms"][parts[0]] = dict(zip(("p50","p95","max"), map(float, parts[1:]), strict=True))
        elif key == "failure":
            result["failures"][parts[0]] = int(parts[1])
        elif key == "barriers":
            result["barrierReports"], result["barrierSquareReads"] = map(int, parts)
        elif key == "traffic":
            result.update(dict(zip(("observationFrames","permitEntries","damagePackets","peakOutstanding","plate1Transitions",
                                    "plate2Transitions","observerPackets"), [int(parts[i]) for i in (0,1,2,4,6,7,9)], strict=True)))
        elif key == "arrivals":
            result["model"] = {str(n): receipt_model(parts, leg, n) for n in (1, 2, 4)}
            for model in result["model"].values():
                if model["applied"] + model["expired"] != len(parts):
                    raise ValueError("Missing contact in receipt model")
        elif key == "cutoff":
            result["cutoff"][parts[0]] = int(parts[1])
    result["suiteAssertions"] = int(float(output.split("Assertions passed: ")[1].splitlines()[0]))
    if len(result["families"]) != 23:
        raise ValueError(f"{label} missing sources")
    print(label, "failures", result["failures"], "server p95", result["ms"]["server"]["p95"], flush=True)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repeat", type=int, default=3)
    parser.add_argument("--trace-only", action="store_true", help="Model serialized and grouped receipts from the same 150 ms arrival trace")
    args = parser.parse_args()
    OUT.mkdir(parents=True, exist_ok=True)
    subprocess.run(["C:/Program Files/Java/jdk-17/bin/javac.exe", "-d", OUT, ROOT / "tools/KahluaCheck.java"], check=True)
    overlay = comparison_overlay()
    if args.trace_only:
        result = run(150, "trace", 1, overlay, trace=True)
        (OUT / "trace.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
        return
    results = []
    for repeat in range(1, args.repeat+1):
        for leg in (50, 150):
            variants = ("stock","index") if repeat % 2 else ("index","stock")
            for variant in variants:
                results.append(run(leg, variant, repeat, overlay))
                (OUT / "results.json").write_text(json.dumps(results, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
