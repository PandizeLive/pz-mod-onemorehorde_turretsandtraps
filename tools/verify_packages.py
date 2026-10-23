import json
import re
from pathlib import Path

from build_packages import IDS, ROOT, build

OPTIONAL_TRAPS = {
    "OMHTT/ControlClient": {"OMHTT/Turret", "OMHTT/TurretTransferAction"},
    # Manage callbacks are invoked only by the Turrets-only management window.
    "OMHTT/ControlManage": {"OMHTT/TurretAccess", "OMHTT/Turret", "OMHTT/TurretFacingCursor"},
    # Poke rows return before the turret-only inventory job.
    "OMHTT/ControlGraphStats": {"OMHTT/Turret", "OMHTT/TurretAmmo", "OMHTT/Firearms",
                              "OMHTT/FirearmFeed", "OMHTT/TurretVoid", "OMHTT/TurretHeads"},
    # Invoked by ControlWorld only for turret receivers.
    "OMHTT/ControlCycle": {"OMHTT/Turret", "OMHTT/TurretClock", "OMHTT/TurretWorld", "OMHTT/TurretAutomation", "OMHTT/TurretModules"},
    # This branch requires an existing OMHTTTurret source container.
    "OMHTT/ControlTransferAction": {"OMHTT/Turret", "OMHTT/TurretTransferAction"},
    "OMHTT/ControlPanel": {"OMHTT/TurretManage"},
    "OMHTT/ControlPanelLayout": {"OMHTT/Turret"},
    "OMHTT/ControlWorld": {"OMHTT/Turret", "OMHTT/TurretAutomation", "OMHTT/TurretWorld"},
    "OMHTT/ControlAction": {"OMHTT/Turret", "OMHTT/TurretWorld"},
    "OMHTT/TurretItemState": {"OMHTT/TurretVoid"},
}


OPTIONAL_TURRETS = {"OMHTT/ControlWorld": {"OMHTT/TetherServer"}}


def main():
    version, packages = build(check=True)
    option_sets = {}
    for component, files in packages.items():
        lua = {Path(name).with_suffix("").as_posix().split("/lua/", 1)[1].split("/", 1)[1]: data.decode()
               for name, data in files.items() if name.endswith(".lua") and "/lua/" in name}
        for name, text in lua.items():
            for match in re.finditer(r'require\("(OMHTT/[^"\n]+)"\)', text):
                dependency = match[1]
                if dependency not in lua:
                    line = text[text.rfind('\n', 0, match.start()) + 1:match.start()]
                    assert dependency in (OPTIONAL_TRAPS if component == 'traps' else OPTIONAL_TURRETS).get(name, set()) and line.startswith('    '), f"{component}: {name} requires absent {dependency}"
        assert ("42.20/media/registries.lua" in files) == (component == "turrets"), "Trait registry package independence"
        adapter = "OMHTT/BarrierPlacement" if component == "traps" else "OMHTT/TurretInstall"
        assert adapter in lua and "OMHTT/HybridBuild" in lua, "Missing component Building adapter"
        for module in ["TetherCycle", "TetherLane", "TetherMount"]:
            assert ("OMHTT/" + module in lua) == (component == "traps"), "Tether mechanics belong only to Traps"
        options = re.findall(r"option\s+(\w+\.\w+)\s*\{", files["42.20/media/sandbox-options.txt"].decode())
        assert len(options) == len(set(options)), component + " has duplicate options"
        option_sets[component] = set(options)
        info = files["42.20/mod.info"].decode()
        assert "require=" not in info and "incompatible=" not in info, component + " is not independent"
        assert "id=" + IDS[component] + "\n" in info
        scripts = "\n".join(data.decode() for name, data in files.items() if "/scripts/" in name)
        # Every custom world model and texture referenced by the shared visual script ships independently.
        visuals = files["42.20/media/scripts/OMHTT_DeviceVisuals.txt"].decode()
        for mesh in re.findall(r"mesh\s*=\s*(\w+)", visuals):
            assert "42.20/media/models_X/" + mesh + ".x" in files, (component, mesh)
        for texture in re.findall(r"texture\s*=\s*([\w/]+)", visuals):
            assert "42.20/media/textures/" + texture + ".png" in files, (component, texture)
        if component == "traps":
            assert not any(name.startswith(("OMHTT/Turret", "OMHTT/Firearm"))
                           and name not in {"OMHTT/TurretBattery", "OMHTT/TurretItemState"} for name in lua)
            assert "OMHTT/ModuleLoot" not in lua and "OMHTT/PrototypeCombat" not in lua
            assert "item OMHTTTurretBase" not in scripts and "item OMHTTModuleFiring" not in scripts
            allowed_models = {"OMHTT_TetherNail.x", "OMHTT_TetherCable.x", "OMHTT_StateAmber.x", "OMHTT_StateGreen.x", "OMHTT_StateDark.x"}
            allowed_sounds = {"OMHTTReeling.wav", "OMHTTLaserCleared.wav", "OMHTTLaserDetected.wav", "OMHTTTurretAlert.wav", "OMHTTTurretDeactivate.wav"}
            assert all(Path(name).name in allowed_models for name in files if "/models_X/" in name)
            assert all(Path(name).name in allowed_sounds for name in files if "/sound/" in name)
            assert "OMHTurretsTraps.PotatoTurret" not in options
        else:
            assert not any(name.startswith("OMHTT/Barrier") for name in lua)
            assert "OMHTT/FoundationServer" not in lua and "OMHTT/Construction" not in lua
            assert "item OMHTTTrapSpikeBarrier" not in scripts
            assert "OMHTurretsTraps.SpikeBarrier" not in options
    assert not option_sets["traps"] & option_sets["turrets"], "Duplicate native Sandbox identities"
    all_options = set(re.findall(r"option\s+(\w+\.\w+)\s*\{", (ROOT / "Source/42.20/media/sandbox-options.txt").read_text()))
    normalized_options = {name.replace("OMHTurretsTraps.Traps", "OMHTurretsTraps.") for name in option_sets["traps"] | option_sets["turrets"]}
    assert all_options == normalized_options, "Sandbox options lost during split"
    common = packages["traps"].keys() & packages["turrets"].keys()
    control_script = "42.20/media/scripts/OMHTT_Controls.txt"
    normalized = packages['turrets'][control_script]
    for facing in range(4):
        normalized = normalized.replace(f'omhtt_turret_01_{21 + facing}'.encode(), f'omhtt_barrier_01_{76 + facing}'.encode())
    for facing in range(5):
        normalized = normalized.replace(f'omhtt_turret_01_{25 + facing}'.encode(), f'omhtt_barrier_01_{80 + facing}'.encode())
    for facing in range(8):
        normalized = normalized.replace(f'omhtt_turret_01_{30 + facing}'.encode(), f'omhtt_barrier_01_{94 + facing}'.encode())
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
