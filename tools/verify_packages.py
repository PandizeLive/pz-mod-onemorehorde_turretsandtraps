import json
import re
from pathlib import Path

from build_packages import IDS, ROOT, build


def main():
    version, packages = build(check=True)
    option_sets = {}
    for component, files in packages.items():
        lua = {Path(name).with_suffix("").as_posix().split("/lua/", 1)[1].split("/", 1)[1]: data.decode()
               for name, data in files.items() if name.endswith(".lua")}
        for name, text in lua.items():
            for dependency in re.findall(r'require\("(OMHTT/[^"\n]+)"\)', text):
                assert dependency in lua, f"{component}: {name} requires absent {dependency}"
        options = re.findall(r"option\s+(\w+\.\w+)\s*\{", files["42.20/media/sandbox-options.txt"].decode())
        assert len(options) == len(set(options)), component + " has duplicate options"
        option_sets[component] = set(options)
        info = files["42.20/mod.info"].decode()
        assert "require=" not in info and "incompatible=" not in info, component + " is not independent"
        assert "id=" + IDS[component] + "\n" in info
        scripts = "\n".join(data.decode() for name, data in files.items() if "/scripts/" in name)
        if component == "traps":
            assert not any(name.startswith(("OMHTT/Turret", "OMHTT/Firearm")) for name in lua)
            assert "OMHTT/ModuleLoot" not in lua and "OMHTT/PrototypeCombat" not in lua
            assert "item OMHTTTurretBase" not in scripts and "item OMHTTModuleFiring" not in scripts
            assert not any("/models_X/" in name or "/sound/" in name for name in files)
            assert "OMHTurretsTraps.PotatoTurret" not in options
        else:
            assert not any(name.startswith("OMHTT/Barrier") for name in lua)
            assert "OMHTT/FoundationServer" not in lua and "OMHTT/Construction" not in lua
            assert "item OMHTTSpikeBarrierItem" not in scripts
            assert "OMHTurretsTraps.SpikeBarrier" not in options
    assert not option_sets["traps"] & option_sets["turrets"], "Sandbox controls overlap"
    all_options = set(re.findall(r"option\s+(\w+\.\w+)\s*\{", (ROOT / "Source/42.20/media/sandbox-options.txt").read_text()))
    assert all_options == option_sets["traps"] | option_sets["turrets"], "Sandbox options lost during split"
    common = packages["traps"].keys() & packages["turrets"].keys()
    virtual_overrides = {"42.20/mod.info", "42.20/media/sandbox-options.txt"}
    for name in common - virtual_overrides:
        assert packages["traps"][name] == packages["turrets"][name], "Diverging common file: " + name
    result = {"version": version, "closedLuaDependencies": True, "uniqueSandboxOptions": len(all_options),
              "independentEntries": True, "sharedFilesIdentical": len(common - virtual_overrides)}
    output = ROOT / "diagnostics" / ("v" + version)
    output.mkdir(parents=True, exist_ok=True)
    (output / "package-static.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(result))


if __name__ == "__main__":
    main()
