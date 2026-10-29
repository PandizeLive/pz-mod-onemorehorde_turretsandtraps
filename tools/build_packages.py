import argparse
import json
import re
from pathlib import Path

from build_barrier_tiles import build_component

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "Source"
PACKAGES = ROOT / "Contents/mods"
IDS = {"traps": "OneMoreHorde_Traps", "turrets": "OneMoreHorde_Turrets"}
SHARED_LUA = {"WindowGeometry", "DefenseNames", "DefenseXP", "SlotHint", "DefenseAuthority", "DefenseActorState", "DefenseContacts", "DefenseLine", "DefenseInjury", "DefenseEffects", "DefenseMotion", "DefenseDisplacement", "DefenseCombatProtocol", "DefenseCombatServer", "DefenseCombatClient", "DefenseHorde", "ContactPlayer", "BarbMovement", "BarbContact", "ActiveTime", "Foundation", "Diagnostics", "Damage", "DamagePresentation", "DamageNotice", "ConstructionMenu", "CraftingMenu", "CraftingGroups", "HybridBuild", "SandboxUI", "WorldHighlight", "PackageInfo", "PlacementTiming", "PlacementRules", "PlacementAction", "PlacementBuild"}
TRAP_LUA = {"FoundationServer", "FoundationClient", "DevMarkers", "Construction", "DefenseMaterials"}
TRAP_SCRIPTS = {"OMHTT_Items.txt", "OMHTT_PortableBarrier.txt", "OMHTT_construction.txt", "OMHTT_construction_ui.txt", "OMHTT_BedSpikes.txt", "OMHTT_Barbs.txt", "OMHTT_PokeFloor.txt", "OMHTT_Tether.txt"}
TRAP_OPTIONS = {"Enabled", "FoundationTestControls", "DiagnosticLogging", "ShowCollision", "DetailedLogging"}


def owner(path):
    name = path.name
    relative = path.as_posix()
    if name == "mod.info" or name == "sandbox-options.txt" or name.endswith((".tiles", ".pack")):
        return set()
    if name == "icon.png" or "/Translate/" in relative:
        return set(IDS)
    if name == "registries.lua":
        return {"turrets"}
    if "/shaders/" in relative:
        return set(IDS)
    if path.suffix == ".lua":
        if path.stem in SHARED_LUA or path.stem.startswith("Control") or path.stem in {"TurretBattery", "TurretItemState"}:
            return set(IDS)
        if path.stem.startswith(("Barrier", "Bed", "Barb", "Tether")) or path.stem in TRAP_LUA:
            return {"traps"}
        if path.stem.startswith(("Turret", "Firearm", "Hybrid", "Prototype")) or path.stem in {"ModuleLoot", "LootDefinitions", "TargetHealth", "ClientOptions"}:
            return {"turrets"}
        raise ValueError("Unassigned Lua module: " + relative)
    if "/scripts/" in relative:
        if name in {"OMHTT_Controls.txt", "OMHTT_DeviceSounds.txt", "OMHTT_DeviceVisuals.txt", "OMHTT_ControllerKits.txt"}:
            return set(IDS)
        return {"traps"} if name in TRAP_SCRIPTS else {"turrets"}
    if "/AnimSets/" in relative:
        return set(IDS)
    if any(key in relative for key in ("/models_X/OMHTT_Tether", "/models_X/OMHTT_State", "/textures/OMHTT/State", "/textures/OMHTT/ProbeWhite")):
        return set(IDS)
    if "/textures/OMHTT/Modules/expansion_" in relative:
        return set(IDS)
    if "/textures/" in relative:
        if name in {"OMHTT_TestCube.png", "OMHTT_Foundation.png"}:
            return {"traps"}
        return {"traps"} if "Barrier" in name or "BedSpikes" in name or "ConcertinaWire" in name else {"turrets"}
    if "/sound/OMHTT" in relative and any(key in name for key in ("Reeling", "Laser", "TurretAlert", "TurretDeactivate")):
        return set(IDS)
    if relative.startswith("common/") or "/models_X/" in relative or "/sound/" in relative:
        return {"turrets"}
    raise ValueError("Unassigned package file: " + relative)


def sandbox(component):
    content = (SOURCE / "42.20/media/sandbox-options.txt").read_text(encoding="utf-8")
    blocks = re.findall(r"option OMHTurretsTraps\.(\w+)\s*\{[^}]+\}", content)
    result = ["VERSION = 1,\n"]
    for match in re.finditer(r"option OMHTurretsTraps\.(\w+)\s*\{[^}]+\}", content):
        key = match[1]
        trap = key in TRAP_OPTIONS or "Barrier" in key or key.startswith(("Bed", "Barb", "Poke", "Tether"))
        if key.startswith(("Trigger", "Controller", "DefenseXP")) or key in {"LaserRange", "DeviceSoundVolume", "ModuleLootRate", "LootRateCapacitySmall", "LootRateCapacity", "LootRateCapacityLarge", "RarityWeightAbundant", "RarityWeightCommon", "RarityWeightUncommon", "RarityWeightRare", "RarityWeightEpic", "RarityWeightLegendary", "RarityWeightMythic"} or trap == (component == "traps"):
            block = match[0]
            if component == "traps" and (key.startswith(("Trigger", "Controller", "DefenseXP")) or key in {"LaserRange", "DeviceSoundVolume", "ModuleLootRate", "LootRateCapacitySmall", "LootRateCapacity", "LootRateCapacityLarge", "RarityWeightAbundant", "RarityWeightCommon", "RarityWeightUncommon", "RarityWeightRare", "RarityWeightEpic", "RarityWeightLegendary", "RarityWeightMythic"}):
                block = block.replace("option OMHTurretsTraps." + key, "option OMHTurretsTraps.Traps" + key, 1)
            result.append(block + "\n")
    assert blocks and len(result) > 1
    return ("\n".join(result)).encode()


def expected_files():
    version = re.search(r"^modversion=(.+)$", (SOURCE / "42.20/mod.info").read_text(), re.M)[1].strip()
    result = {component: {} for component in IDS}
    for path in sorted(SOURCE.rglob("*")):
        if not path.is_file() or path.name in {".gitkeep", ".keep"}:
            continue
        relative = path.relative_to(SOURCE)
        for component in owner(relative):
            result[component][relative.as_posix()] = path.read_bytes()
    for component, identifier in IDS.items():
        title = component.title()
        pack = "OMHTT_Traps" if component == "traps" else "OMHTT_Turrets"
        number = 7316 if component == "traps" else 7317
        description = ("Independent Spike Barriers, Bed Spikes, Concertina Wire and backed Barbed Panels: crafting, placement, repair and portable defenses."
                       if component == "traps" else "Independent modular potato, firearm, Ballista and rotary turrets, modules, power and component loot.")
        description += " Development build with server-authoritative multiplayer paths; connected multiplayer acceptance is pending."
        info = f"name=OMH: {title}\nid={identifier}\nmodversion={version}\nversionMin=42.20\nicon=icon.png\ndescription={description} Part of OMH: Turrets & Traps. Fresh test world required for 0.2.41 item identities. Temporary developer artwork.\ntiledef={pack} {number}\npack={pack}\n"
        files = result[component]
        files["42.20/mod.info"] = info.encode()
        if component == "turrets":
            path = "42.20/media/scripts/OMHTT_Controls.txt"
            for facing in range(4):
                files[path] = files[path].replace(f"omhtt_barrier_01_{76 + facing}".encode(), f"omhtt_turret_01_{21 + facing}".encode())
            for facing in range(5):
                files[path] = files[path].replace(f"omhtt_barrier_01_{80 + facing}".encode(), f"omhtt_turret_01_{25 + facing}".encode())
        if component == "turrets":
            for facing in range(8):
                files[path] = files[path].replace(f"omhtt_barrier_01_{94 + facing}".encode(), f"omhtt_turret_01_{30 + facing}".encode())
        files["42.20/media/sandbox-options.txt"] = sandbox(component)
        tiles, texturepack = build_component(component)
        files[f"42.20/media/{pack}.tiles"] = tiles
        files[f"42.20/media/texturepacks/{pack}.pack"] = texturepack
        for layer in ["common", "42.20"]:
            for directory in ["AnimSets", "actiongroups", "lua/client", "lua/server", "lua/shared"]:
                files[f"{layer}/media/{directory}/.gitkeep"] = b""
    return version, result


def build(check=False):
    version, expected = expected_files()
    for component, files in expected.items():
        package = PACKAGES / IDS[component]
        existing = {p.relative_to(package).as_posix() for p in package.rglob("*") if p.is_file()}
        extra = existing - files.keys()
        if extra:
            raise RuntimeError(f"Unexpected files in generated {component} package; inspect before retirement: {sorted(extra)}")
        for relative, content in files.items():
            target = package / relative
            if check:
                assert target.is_file() and target.read_bytes() == content, "Stale generated file: " + str(target)
            else:
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(content)
    return version, expected


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    version, files = build(parser.parse_args().check)
    print(json.dumps({"version": version, "packages": {IDS[k]: len(v) for k, v in files.items()}}))
