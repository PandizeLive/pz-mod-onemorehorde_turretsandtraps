import hashlib
import json
import os
import re
import subprocess
import zipfile
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
GAME = Path(os.environ.get("PZ_GAME_DIR", "C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid"))
PACKAGE = ROOT / "Source"
VERSION = re.search(r"^modversion=(.+)$", (PACKAGE / "42.20/mod.info").read_text(), re.MULTILINE).group(1).strip()
OUTPUT = ROOT / "diagnostics" / ("v" + VERSION)


def run(command, cwd=None):
    result = subprocess.run([str(arg) for arg in command], capture_output=True, text=True, encoding="utf-8", errors="replace", cwd=cwd)
    text = result.stdout + result.stderr
    print(text, end="")
    if result.returncode:
        raise RuntimeError(f"Command failed with exit code {result.returncode}")
    return text


def main():
    from build_sound_pitch import build as check_pitch
    check_pitch(check=True)
    from build_packages import build
    _, packages = build(check=True)
    OUTPUT.mkdir(parents=True, exist_ok=True)
    classes = OUTPUT / "classes"
    classes.mkdir(exist_ok=True)
    from check_device_render import check as check_device_render
    check_device_render(GAME, OUTPUT)
    texts = list(PACKAGE.rglob("*.lua")) + list(PACKAGE.rglob("*.txt")) + list(PACKAGE.rglob("*.json")) + list(PACKAGE.rglob("mod.info"))
    for path in texts:
        data = path.read_bytes()
        assert not data.startswith(b"\xef\xbb\xbf"), f"BOM: {path}"
        content = data.decode("utf-8")
        assert "\t" not in content, f"Tabs: {path}"
        if path.suffix == ".lua":
            assert not re.search(r"\b(?:ipairs|pcall|xpcall|next)\s*\(", content), f"Banned construct: {path}"
    assert re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+(?:\.[0-9]+)?", VERSION), "Numeric release version required"
    assert f'VERSION = "{VERSION}"' in (PACKAGE / "42.20/media/lua/shared/OMHTT/Foundation.lua").read_text()
    ui_script = (PACKAGE / "42.20/media/scripts/OMHTT_construction_ui.txt").read_text()
    icon = re.search(r"Icon\s*=\s*([^,\s]+)", ui_script).group(1)
    assert "/" not in icon and "." not in icon, "Native trygetTexture adds media/textures/ and .png"
    assert (PACKAGE / "42.20/media/textures" / (icon + ".png")).is_file(), "Missing construction UI icon"
    lua = "\n".join(path.read_text() for path in PACKAGE.rglob("*.lua"))
    translation_files = list((PACKAGE / "42.20/media/lua/shared/Translate/EN").glob("*.json"))
    assert {p.name for p in translation_files} == {"ContextMenu.json", "UI.json", "Sandbox.json", "Recipes.json", "IG_UI.json", "ItemName.json", "Tooltip.json"}
    assert not list(PACKAGE.rglob("*_EN.txt")), "Obsolete translation format is not loaded by the target build"
    translations = {}
    for path in translation_files:
        values = json.loads(path.read_text(encoding="utf-8"))
        assert all(isinstance(v, str) for v in values.values())
        assert not translations.keys() & values.keys(), "Duplicate translation keys"
        translations.update(values)
    keys = set(re.findall(r'getText\("([A-Za-z0-9_]+)"', lua)) - {"UI_OMHTT_", "ContextMenu_OMHTT_Hybrid", "UI_OMHTT_Module", "UI_OMHTT_Effect", "UI_OMHTT_Rarity", "UI_OMHTT_Stack", "UI_OMHTT_HeadFeature", "UI_OMHTT_Control", "UI_OMHTT_TriggerCost", "UI_OMHTT_Target", "UI_OMHTT_DevicePurpose", "Sandbox_OMHTurretsTraps_"}
    keys.update("UI_OMHTT_DevicePurpose" + key for key in ["Barrier", "Bed", "Barb", "Wire", "Poke", "Tether", "Controller", "Button", "Plate", "Lever", "Laser"])
    keys.update("UI_OMHTT_Target" + key for key in ["Zombies", "OtherFactions", "Inherit"])
    keys.update("UI_OMHTT_Control" + key for key in ["Controller", "Plate", "Button"])
    keys.update("UI_OMHTT_Stack" + key for key in ["Magazine", "Rate", "Reload", "Range", "Velocity", "Chance", "Damage", "Threshold", "Radius", "Battery", "Uses", "Shots", "Piercing", "Suppression"])
    keys.update("UI_OMHTT_HeadFeature" + key for key in ["Potato", "Ballista", "Lobber", "Scrapshot", "RotaryBat", "RotaryBlades", "Firearm"])
    keys.update("UI_OMHTT_Rarity" + str(band) for band in range(1, 8))
    keys.update("ContextMenu_OMHTT_Hybrid" + action for action in ["Create", "Remove", "Rotate", "Spin", "Raise", "Lower", "Larger", "Smaller"])
    keys.update("UI_OMHTT_" + status for status in [
        "Agrees", "Waiting", "Denied", "VersionMismatch", "TooFar", "Unavailable", "Inspected", "Stale",
        "Occupied", "Blocked", "Limit", "Placed", "Conflict", "Changed", "Removed", "MPCombatDeferred",
        "WrongDevice", "Empty", "Cooling", "NoTarget", "Fired", "Refilled", "Aimed", "NotCompared", "WrongBarrier", "BarrierRotated",
    ])
    keys.update("UI_OMHTT_Manage" + status for status in ['Drop', 'Hint', 'Head', 'Battery', 'Ammo', 'Modules', 'Module', 'Locked', 'ModulesHint', 'PowerNone', 'PowerExternal', 'PowerBattery', 'PowerDisabled', 'Stats', 'Timing', 'Fire', 'Off', 'Queued', 'TransferMissing', 'TransferReach', 'CapacityFull', 'UnloadFirst', 'TransferFavorite', 'TransferWrongItem', 'TransferFull', 'TransferCarried', 'TransferPending', 'NoHead', 'NoPower', 'Empty', 'Ready', 'Cooling', 'Reloading', 'NoTarget', 'Fired', 'Unavailable', 'MPCombatDeferred', 'WrongDevice', 'Disabled', 'Jammed', 'NoMagazine', 'Racking', 'WrongAmmo'])
    keys.update("UI_OMHTT_Effect" + name for name in ["Damage", "Shots", "Stagger", "Ammo", "HP", "Piercing", "Magazine", "Range", "Rate", "Reload", "Chance", "Noise", "Active", "Inactive", "Broken", "Capped", "Degrees", "Detection"])
    keys.update("UI_OMHTT_Module" + name for name in ["Firing", "MotionDetection", "Filter", "Detection360"])
    keys.update("UI_OMHTT_Priority" + name for name in ["Closest", "Furthest", "Weakest", "Toughest"])
    keys.update(["UI_OMHTT_PowerOn", "UI_OMHTT_PowerOff", "UI_OMHTT_PriorityRandom"])
    for key in keys:
        assert key in translations, f"Missing translation: {key}"
    sandbox = (PACKAGE / "42.20/media/sandbox-options.txt").read_text()
    for key in re.findall(r"translation\s*=\s*(\w+)", sandbox):
        assert "Sandbox_" + key in translations and "Sandbox_" + key + "_tooltip" in translations, key
    for page in re.findall(r"page\s*=\s*(\w+)", sandbox):
        assert translations["Sandbox_" + page].startswith("OMH: T&T - "), page
    item_script = (PACKAGE / "42.20/media/scripts/OMHTT_TurretItems.txt").read_text()
    for key in re.findall(r"Tooltip\s*=\s*(\w+)", item_script):
        assert key in translations and "prototype" not in translations[key].lower(), key
    textures = list((PACKAGE / "42.20/media/textures").glob("*.png"))
    assert len(textures) == 47, "Existing technical markers and owner Performance/Utility/Effects icons required"
    owner_art = json.loads((ROOT / "art/MODULE_ART_C423.json").read_text())
    assert len(owner_art) == 16
    effects_art = json.loads((ROOT / "art/MODULE_ART_C424.json").read_text())
    assert len(effects_art) == 8
    owner_art.extend(effects_art)
    automation_art = json.loads((ROOT / "art/MODULE_ART_C427.json").read_text())
    assert len(automation_art) == 8
    owner_art.extend(automation_art)
    for asset in owner_art:
        path = ROOT / asset["target"]
        assert hashlib.sha256(path.read_bytes()).hexdigest() == asset["sha256"], "Owner artwork must remain unchanged"
        with Image.open(path) as icon:
            assert icon.size == ((28, 29) if "automation" in path.name.lower() else (32, 32)) and icon.mode == "RGBA" and icon.getbbox()
    for heading, index in zip("ENWS", range(4)):
        for part in "AB":
            assert (PACKAGE / f"42.20/media/textures/OMHTT_BuildBarrier{heading}_{part}.png").read_bytes() == (PACKAGE / f"42.20/media/textures/OMHTT_Barrier{index}.png").read_bytes(), "Construction sprites reuse authorized technical markers"
    assert (PACKAGE / "42.20/media/textures/Item_OMHTT_Barrier0.png").read_bytes() == (PACKAGE / "42.20/media/textures/OMHTT_Barrier0.png").read_bytes()
    from build_barrier_tiles import build
    tiles, pack = build()
    assert (PACKAGE / "42.20/media/OMHTT_Barriers.tiles").read_bytes() == tiles
    assert (PACKAGE / "42.20/media/texturepacks/OMHTT_Barriers.pack").read_bytes() == pack
    from build_cube_placeholder import read_export
    from build_foundation_sprite import render, marker
    import copy
    document, binary = read_export()
    base = copy.deepcopy(document)
    base["nodes"][0]["children"] = [1]
    expected_base = render(base, binary, 0, ground_y=192 + 32)
    with Image.open(PACKAGE / "42.20/media/textures/OMHTT_ProbeBase.png") as sprite:
        assert sprite.tobytes() == expected_base.tobytes(), "Base ground center must match native tile center (64,224)"
        assert sprite.getbbox()[3] < 256, "Grounded base must fit the tile texture"
    for facing in range(16):
        expected = render(document, binary, facing / 4, ground_y=224)
        expected.alpha_composite(marker("POTATO", facing, label_y=70))
        with Image.open(PACKAGE / f"42.20/media/textures/OMHTT_Aim{facing}.png") as sprite:
            assert sprite.tobytes() == expected.tobytes(), "Fallback turret must share the grounded tile anchor"
    barrier_bytes = {(PACKAGE / f"42.20/media/textures/OMHTT_Barrier{i}.png").read_bytes() for i in range(4)}
    assert len(barrier_bytes) == 4, "Barrier directions must have distinct pixels"
    for texture in textures:
        with Image.open(texture) as sprite:
            expected_size = (28, 29) if texture.name == "Item_OMHTT_ModuleAutomation.png" else (32, 32) if texture.name in {"Item_OMHTT_ModulePerformance.png", "Item_OMHTT_ModuleUtility.png", "Item_OMHTT_ModuleEffects.png"} else (60, 36) if texture.name in {"Item_OMHTT_BedSpikes.png", "Item_OMHTT_ReinforcedBedSpikes.png"} else (128, 256)
            assert sprite.size == expected_size and sprite.mode == "RGBA"
            assert sprite.getbbox() is not None
            if texture.name not in {"Item_OMHTT_ModuleAutomation.png", "Item_OMHTT_ModulePerformance.png", "Item_OMHTT_ModuleUtility.png", "Item_OMHTT_ModuleEffects.png"}:
                assert all(r == g == b for r, g, b, a in sprite.get_flattened_data() if a), "Technical sprites must remain white/grayscale"
    javac = Path(os.environ.get("PZ_JAVAC", "C:/Program Files/Java/jdk-17/bin/javac.exe"))
    run([javac, "-d", classes, ROOT / "tools/NativePitchCheck.java"])
    pitch_log = run([GAME / "jre64/bin/java.exe", "--enable-native-access=ALL-UNNAMED",
        "-Djava.library.path=" + str(GAME), "-cp", os.pathsep.join([str(classes), str(GAME / "projectzomboid.jar")]),
        "NativePitchCheck", PACKAGE / "42.20", OUTPUT / "pitch-cache", GAME], cwd=GAME)
    assert "NATIVE_PITCH_PASS definitions=24 clips=2727 plays=720" in pitch_log
    assert "NATIVE_PACK_AUDIO_PASS tiers=7 nativeUIHandles=7 stopped=7" in pitch_log
    assert "Set pitch for" not in pitch_log, "Runtime pitch setter logging returned"
    (OUTPUT / "native-pitch.log").write_text(pitch_log, encoding="utf-8")
    run([javac, "-d", classes, ROOT / "tools/KahluaCheck.java"])
    run([javac, "-d", classes, ROOT / "tools/NativeControllerMapCheck.java"])
    run([javac, "-cp", GAME / "projectzomboid.jar", "-d", classes, ROOT / "tools/HybridAssetCheck.java"])
    model_log = run([GAME / "jre64/bin/java.exe", "--enable-native-access=ALL-UNNAMED",
        "-Djava.library.path=" + str(GAME), "-cp", os.pathsep.join([str(classes), str(GAME / "projectzomboid.jar")]),
        "HybridAssetCheck", PACKAGE / "42.20/media/models_X/OMHTT_ProbeHead.x"], cwd=GAME)
    model_log += run([GAME / "jre64/bin/java.exe", "--enable-native-access=ALL-UNNAMED",
        "-Djava.library.path=" + str(GAME), "-cp", os.pathsep.join([str(classes), str(GAME / "projectzomboid.jar")]),
        "HybridAssetCheck", PACKAGE / "42.20/media/models_X/OMHTT_GunSupport.x", "36"], cwd=GAME)
    model_log += run([GAME / "jre64/bin/java.exe", "--enable-native-access=ALL-UNNAMED",
        "-Djava.library.path=" + str(GAME), "-cp", os.pathsep.join([str(classes), str(GAME / "projectzomboid.jar")]),
        "HybridAssetCheck", PACKAGE / "42.20/media/models_X/OMHTT_Arc.x", "4"], cwd=GAME)
    (OUTPUT / "model-import.log").write_text(model_log, encoding="utf-8")
    run([javac, "-d", classes, ROOT / "tools/BuildBaseDepth.java"])
    depth_log = run([GAME / "jre64/bin/java.exe", "--enable-native-access=ALL-UNNAMED",
        "-Djava.library.path=" + str(GAME), "-cp", os.pathsep.join([str(classes), str(GAME / "projectzomboid.jar")]),
        "BuildBaseDepth", PACKAGE / "42.20/media/textures/OMHTT_ProbeBase.png", OUTPUT / "base-depth.png", PACKAGE / "common/media"], cwd=GAME)
    assert (OUTPUT / "base-depth.png").read_bytes() == (PACKAGE / "common/media/depthmaps/DEPTH_omhtt_turret_01.png").read_bytes()
    (OUTPUT / "base-depth.log").write_text(depth_log, encoding="utf-8")
    pages = list(dict.fromkeys(re.findall(r"page\s*=\s*(\w+)", sandbox)))
    assert pages == ["OMHTurretsTraps_General", "OMHTurretsTraps_BarrierPage", "OMHTurretsTraps_PotatoPage",
                     "OMHTurretsTraps_StatModulesPage", "OMHTurretsTraps_ModuleLootPage", "OMHTurretsTraps_Debug", "OMHTurretsTraps_TriggersPage"]
    for asset in ("TetherNail", "TetherCable", "StateAmber", "StateGreen", "StateDark"):
        run([GAME / "jre64/bin/java.exe", "--enable-native-access=ALL-UNNAMED", "-cp", os.pathsep.join([str(classes), str(GAME / "projectzomboid.jar")]),
             "HybridAssetCheck", PACKAGE / ("42.20/media/models_X/OMHTT_" + asset + ".x"), "12"], cwd=GAME)
    stock = os.environ.get("OMHTT_STOCK_CLASSES") == "1"
    classpath = os.pathsep.join(str(path) for path in ([classes, GAME / "projectzomboid.jar", GAME] if stock else [classes, GAME, GAME / "projectzomboid.jar"]))
    map_log = run([GAME / "jre64/bin/java.exe", "--enable-native-access=ALL-UNNAMED", "-Djava.awt.headless=true",
        "-Duser.home=" + str(OUTPUT / "native-home"), "-cp", classpath, "NativeControllerMapCheck"], cwd=GAME)
    (OUTPUT / "native-controller-map.log").write_text(map_log, encoding="utf-8")
    log = run([GAME / "jre64/bin/java.exe", "--enable-native-access=ALL-UNNAMED", "-Djava.awt.headless=true",
        "-Duser.home=" + str(OUTPUT / "native-home"), "-cp", classpath, "KahluaCheck", ROOT, "tools/tests/module_pack_audit.lua"], cwd=GAME)
    (OUTPUT / "validation.log").write_text(log, encoding="utf-8")
    files = {str(path.relative_to(PACKAGE)).replace("\\", "/"): hashlib.sha256(path.read_bytes()).hexdigest()
        for path in sorted(PACKAGE.rglob("*")) if path.is_file()}
    sources = [
        "media/AnimSets/zombie/knockeddown-headTop/HeadTopFall.xml",
        "media/anims_X/Zombie/Zombie_HitDeath_HeadTop.x",
        "media/AnimSets/zombie/climbfence/start.xml",
        "media/AnimSets/zombie/falldown/frombehind.xml",
        "media/scripts/generated/sounds/zombies/sounds_zombie_foley.txt",
        "media/scripts/generated/sounds/weapons/sounds_melee_spears.txt",
        "media/lua/server/BuildingObjects/ISBuildingObject.lua",
        "media/scripts/generated/items/weapon.txt",
        "media/scripts/generated/models_weapons.txt",
        "media/lua/shared/TimedActions/ISReloadWeaponAction.lua",
        "media/lua/shared/TimedActions/ISInsertMagazine.lua",
        "media/lua/shared/TimedActions/ISEjectMagazine.lua",
        "media/lua/shared/TimedActions/ISRackFirearm.lua",
        "zombie/inventory/types/HandWeapon.class",
        "zombie/iso/objects/IsoBulletTracerEffects.class",

        "projectzomboid.jar", "zombie/iso/IsoObject.class", "zombie/core/Core.class",
        "media/lua/server/Map/SGlobalObjectSystem.lua", "media/lua/server/Camping/SCampfireGlobalObject.lua",
        "media/lua/server/Vehicles/ProfessionVehicles.lua", "media/lua/server/ClientCommands.lua",
        "zombie/characters/IsoZombie.class", "zombie/characters/IsoGameCharacter.class",
        "media/AnimSets/zombie/thump/DoorBang.xml", "media/AnimSets/zombie/thump/DoorClaw.xml",
        "media/actiongroups/zombie/thump/to_staggerback-knockeddown.xml",
        "media/lua/server/BuildingObjects/ISBuildIsoEntity.lua",
        "media/lua/client/BuildingObjects/TimedActions/ISBuildAction.lua",
        "media/lua/client/Entity/ISUI/BuildRecipe/ISBuildPanel.lua",
        "media/lua/client/Entity/ISUI/CraftRecipe/ISWidgetRecipeCategories.lua",
        "media/lua/client/Entity/ISUI/CraftRecipe/ISRecipeScrollingListBox.lua",
        "media/lua/client/Entity/ISUI/CraftRecipe/ISTiledIconPanel.lua",
        "zombie/Lua/LuaManager$GlobalObject.class",
        "zombie/entity/components/build/BuildLogic.class",
        "zombie/entity/components/spriteconfig/SpriteConfig.class",
        "zombie/iso/sprite/IsoSpriteManager.class",
        "zombie/iso/objects/IsoThumpable.class",
        "zombie/core/Translator.class",
        "zombie/iso/IsoWorld.class", "zombie/fileSystem/TexturePackDevice.class",
        "zombie/gameStates/ChooseGameInfo.class", "zombie/entity/GameEntityFactory.class",
        "zombie/entity/ComponentType.class", "zombie/inventory/InventoryItem.class",
        "zombie/scripting/objects/Item.class",
        "media/lua/client/TimedActions/ISClimbOverFence.lua",
        "zombie/characters/BodyDamage/BodyPart.class", "zombie/iso/objects/IsoWindow.class",
        "zombie/ai/states/ClimbOverFenceState.class", "zombie/pathfind/SquareUpdateTask.class",
        "zombie/pathfind/nativeCode/SquareUpdateTask.class", "zombie/characters/IsoPlayer.class",
        "zombie/GameTime.class", "zombie/inventory/ItemContainer.class",
        "zombie/inventory/types/InventoryContainer.class", "zombie/iso/objects/IsoGenerator.class",
        "zombie/iso/objects/IsoWorldInventoryObject.class", "zombie/core/skinnedmodel/model/ItemModelRenderer.class",
        "zombie/iso/IsoUtils.class", "zombie/iso/IsoCamera.class", "zombie/ui/UIManager.class", "zombie/core/Core.class",
        "zombie/core/skinnedmodel/model/ItemModelRenderer$WorldModelCamera.class",
        "zombie/core/skinnedmodel/model/WorldItemModelDrawer.class", "zombie/core/skinnedmodel/model/FileTask_LoadMesh.class",
        "zombie/core/skinnedmodel/model/jassimp/ProcessedAiScene.class", "jassimp64.dll",
        "media/lua/server/BuildingObjects/ISPlace3DItemCursor.lua", "media/lua/client/ISUI/ISExtendedPlacementUI.lua",
        "media/lua/client/TimedActions/ISInventoryTransferAction.lua",
        "media/lua/client/ISUI/ISWorldObjectContextMenu.lua",
        "zombie/iso/IsoGridSquare.class", "zombie/iso/IsoObjectUtils.class",
        "media/lua/shared/ISBaseObject.lua",
        "media/lua/shared/Fishing/Bobber.lua", "media/lua/shared/luautils.lua",
        "media/lua/client/ISUI/ISInventoryPane.lua", "media/lua/client/ISUI/ISToolTipInv.lua",
        "media/lua/server/Items/ProceduralDistributions.lua", "media/lua/server/Items/SuburbsDistributions.lua",
        "zombie/inventory/ItemPickerJava.class", "zombie/Lua/LuaEventManager.class", "zombie/SandboxOptions.class",
        "media/lua/client/ISUI/ISButton.lua", "media/lua/shared/Entity/TimedActions/ISHandcraftAction.lua",
        "media/lua/client/ISUI/ISUIElement.lua", "media/lua/client/ISUI/ISPanel.lua",
        "media/lua/client/ISUI/ISScrollingListBox.lua",
        "media/lua/client/Entity/ISUI/Controls/ISItemSlot.lua",
        "media/lua/client/ISUI/ISInventoryPage.lua", "zombie/iso/fboRenderChunk/FBORenderCell.class",
        "media/lua/client/Entity/ISUI/CraftRecipe/ISHandCraftPanel.lua",
        "media/lua/client/Entity/ISUI/Controls/ISWidgetTitleHeader.lua",
        "media/lua/shared/TimedActions/ISBaseTimedAction.lua",
        "media/lua/client/Entity/ISUI/CraftRecipe/ISWidgetInput.lua",
        "media/scripts/generated/entities/animals/workstations/entity_feedingtrough.txt",
        "zombie/entity/components/spriteconfig/SpriteConfigManager.class",
        "zombie/scripting/entity/components/spriteconfig/SpriteConfigScript.class",
        "zombie/entity/components/crafting/recipe/CraftRecipeData.class",
        "zombie/scripting/entity/components/crafting/InputScript.class",
        "media/scripts/generated/recipes/recipes_spears.txt",
        "media/scripts/generated/recipes/recipes_carving.txt",
        "media/scripts/generated/timedactions.txt",
    ]
    evidence = {name: hashlib.sha256((GAME / name).read_bytes()).hexdigest() for name in sources
                if (GAME / name).is_file() and not (stock and name.endswith(".class"))}
    with zipfile.ZipFile(GAME / "projectzomboid.jar") as native:
        for name in sources:
            if name not in evidence and name in native.namelist():
                evidence[name + " (jar)"] = hashlib.sha256(native.read(name)).hexdigest()
    version = re.search(r"^modversion=(.+)$", (PACKAGE / "42.20/mod.info").read_text(), re.MULTILINE).group(1).strip()
    from build_packages import IDS
    package_manifests = {IDS[component]: {name: hashlib.sha256(data).hexdigest() for name, data in contents.items()} for component, contents in packages.items()}
    manifest = {"version": version, "gameRoot": str(GAME), "nativeClassOrder": "stock-jar-first" if stock else "installed-loose-first", "sourceFiles": files, "packages": package_manifests, "gameEvidence": evidence,
        "inGameAcceptance": "pending", "nativeTableFormatVersion": 249}
    (OUTPUT / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(f"Package checks passed: {len(files)} source files, {sum(len(p) for p in package_manifests.values())} packaged files, {len(keys)} translation keys; manifest recorded.")


if __name__ == "__main__":
    main()
