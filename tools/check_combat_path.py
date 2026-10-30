"""Source-only C508 checks. Never builds, stages, installs or uploads packages."""
import argparse
import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
GAME = Path(os.environ.get("PZ_GAME_DIR", "C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid"))
OUTPUT = ROOT / "diagnostics/c508"

def run(command, name, extra_env=None):
    result = subprocess.run([str(part) for part in command], cwd=ROOT, capture_output=True, text=True,
                            encoding="utf-8", errors="replace", env={**os.environ, "OMHTT_TEST_OUTPUT": OUTPUT.relative_to(ROOT).as_posix(), **(extra_env or {})})
    text = result.stdout + result.stderr
    (OUTPUT / (name + ".log")).write_text(text, encoding="utf-8")
    print(text[-3500:])
    if result.returncode:
        raise SystemExit(result.returncode)

def main():
    global OUTPUT
    parser = argparse.ArgumentParser()
    parser.add_argument("--full", action="store_true")
    parser.add_argument("--compare", action="store_true")
    parser.add_argument("--checkpoint", choices=["c508", "c509"], default="c508")
    args = parser.parse_args()
    OUTPUT = ROOT / "diagnostics" / args.checkpoint
    OUTPUT.mkdir(parents=True, exist_ok=True)
    run(["C:/Program Files/Java/jdk-17/bin/javac.exe", "-d", OUTPUT,
         ROOT / "tools/CombatPathCheck.java", ROOT / "tools/KahluaCheck.java"], "compile")
    java = [GAME / "jre64/bin/java.exe", "--enable-native-access=ALL-UNNAMED", "-Djava.awt.headless=true",
            "-Duser.home=" + str(OUTPUT / "native-home"), "-cp", os.pathsep.join(map(str, [OUTPUT, GAME / "projectzomboid.jar", GAME]))]
    modules = ["_=tools/tests/combat_path_setup.lua",
               "DefenseCombatProtocol=Source/42.20/media/lua/shared/OMHTT/DefenseCombatProtocol.lua",
               "DefenseHorde=Source/42.20/media/lua/shared/OMHTT/DefenseHorde.lua",
               "DefenseCombatClient=Source/42.20/media/lua/client/OMHTT/DefenseCombatClient.lua",
               "DefenseCombatServer=Source/42.20/media/lua/server/OMHTT/DefenseCombatServer.lua"]
    for test in ["combat_path_latency", "defense_combat_network"]:
        run([*java, "CombatPathCheck", ROOT, *modules, "_=tools/tests/" + test + ".lua"], test)
    if args.compare:
        baseline = OUTPUT / "baseline"
        baseline.mkdir(exist_ok=True)
        previous = [modules[0]]
        for spec in modules[1:]:
            name, path = spec.split("=", 1)
            result = subprocess.run(["git", "-c", "safe.directory=" + ROOT.as_posix(), "show", "00970de:" + path],
                                    cwd=ROOT, capture_output=True, check=True)
            target = baseline / (name + ".lua")
            target.write_bytes(result.stdout)
            previous.append(name + "=" + target.relative_to(ROOT).as_posix())
        for delay in [25, 50, 100]:
            for label, paths in [("baseline", previous), ("replacement", modules)]:
                run([*java, "CombatPathCheck", ROOT, *paths, "_=tools/tests/combat_path_latency.lua"],
                    f"{label}-{delay}ms", {"OMHTT_TEST_DELAY_MS": str(delay)})
    if args.full:
        run([*java, "KahluaCheck", ROOT, "tools/tests/module_pack_audit.lua"], "full-suite")

if __name__ == "__main__":
    main()
