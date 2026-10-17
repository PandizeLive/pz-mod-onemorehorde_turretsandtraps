import json
import re
from pathlib import Path

from build_packages import IDS, ROOT, build

OPTIONAL_TRAPS = {
    "OMHTT/ControlClient": {"OMHTT/Turret", "OMHTT/TurretTransferAction"},
    "OMHTT/ControlManage": {"OMHTT/TurretAccess"},
    "OMHTT/ControlPanel": {"OMHTT/TurretManage"},
    "OMHTT/ControlPanelLayout": {"OMHTT/Turret"},
    "OMHTT/ControlWorld": {"OMHTT/Turret", "OMHTT/TurretAutomation", "OMHTT/TurretWorld"},
    "OMHTT/ControlAction": {"OMHTT/Turret"},
    "OMHTT/TurretItemState": {"OMHTT/TurretVoid"},
}


def main():
    version, packages = build(check=True)
    option_sets = {}
    for component, files in packages.items():
        lua = {Path(name).with_suffix("").as_posix().split("/lua/", 1)[1].split("/", 1)[1]: data.decode()
               for name, data in files.items() if name.endswith(".lua")}
        for name, text in lua.items():
            for match in re.finditer(r'require\("(OMHTT/[^"\n]+)"\)', text):
                dependency = match[1]
                if dependency not in lua:
                    line = text[text.rfind('\n', 0, match.start()) + 1:match.start()]
                    assert component == 'traps' and dependency in OPTIONAL_TRAPS.get(name, set()) and line.startswith('    '), f"{component}: {name} requires absent {dependency}"
        adapter = "OMHTT/BarrierPlacement" if component == "traps" else "OMHTT/TurretInstall"
        assert adapter in lua and "OMHTT/HybridBuild" in lua, "Missing component Building adapter"
        options = re.findall(r"option\s+(\w+\.\w+)\s*\{", files["42.20/media/sandbox-options.txt"].decode())
        assert len(options) == len(set(options)), component + " has duplicate options"
        option_sets[component] = set(options)
        info = files["42.20/mod.info"].decode()
        assert "require=" not in info and "incompatible=" not in info, component + " is not independent"
        assert "id=" + IDS[component] + "\n" in info
        scripts = "\n".join(data.decode() for name, data in files.items() if "/scripts/" in name)
        if component == "traps":
            assert not any(name.startswith(("OMHTT/Turret", "OMHTT/Firearm"))
                           and name not in {"OMHTT/TurretBattery", "OMHTT/TurretItemState"} for name in lua)
            assert "OMHTT/ModuleLoot" not in lua and "OMHTT/PrototypeCombat" not in lua
            assert "item OMHTTTurretBase" not in scripts and "item OMHTTModuleFiring" not in scripts
            assert not any("/models_X/" in name or "/sound/" in name for name in files)
            assert "OMHTurretsTraps.PotatoTurret" not in options
        else:
            assert not any(name.startswith("OMHTT/Barrier") for name in lua)
            assert "OMHTT/FoundationServer" not in lua and "OMHTT/Construction" not in lua
            assert "item OMHTTTrapSpikeBarrier" not in scripts
            assert "OMHTurretsTraps.SpikeBarrier" not in options
    assert not option_sets["traps"] & option_sets["turrets"], "Sandbox controls overlap"
    all_options = set(re.findall(r"option\s+(\w+\.\w+)\s*\{", (ROOT / "Source/42.20/media/sandbox-options.txt").read_text()))
    assert all_options == option_sets["traps"] | option_sets["turrets"], "Sandbox options lost during split"
    common = packages["traps"].keys() & packages["turrets"].keys()
    control_script = "42.20/media/scripts/OMHTT_Controls.txt"
    normalized = packages['turrets'][control_script]
    for facing in range(4):
        normalized = normalized.replace(f'omhtt_turret_01_{21 + facing}'.encode(), f'omhtt_barrier_01_{76 + facing}'.encode())
    assert normalized == packages['traps'][control_script], 'Controller scripts differ beyond independent sprite identities'
    virtual_overrides = {"42.20/mod.info", "42.20/media/sandbox-options.txt", control_script}
    for name in common - virtual_overrides:
        assert packages["traps"][name] == packages["turrets"][name], "Diverging common file: " + name
    result = {"version": version, "requiredLuaDependenciesClosed": True, "reviewedOptionalTrapsDependencies": sum(map(len, OPTIONAL_TRAPS.values())), "uniqueSandboxOptions": len(all_options),
              "independentEntries": True, "sharedFilesIdentical": len(common - virtual_overrides)}
    output = ROOT / "diagnostics" / ("v" + version)
    output.mkdir(parents=True, exist_ok=True)
    (output / "package-static.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(result))


if __name__ == "__main__":
    main()
