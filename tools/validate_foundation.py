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
PACKAGE = ROOT / "Contents/mods/OneMoreHorde_TurretsAndTraps"
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
    OUTPUT.mkdir(parents=True, exist_ok=True)
    classes = OUTPUT / "classes"
    classes.mkdir(exist_ok=True)
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
    keys = set(re.findall(r'getText\("([A-Za-z0-9_]+)"', lua)) - {"UI_OMHTT_", "ContextMenu_OMHTT_Hybrid", "UI_OMHTT_Module"}
    keys.update("ContextMenu_OMHTT_Hybrid" + action for action in ["Create", "Remove", "Rotate", "Spin", "Raise", "Lower", "Larger", "Smaller"])
    keys.update("UI_OMHTT_" + status for status in [
        "Agrees", "Waiting", "Denied", "VersionMismatch", "TooFar", "Unavailable", "Inspected", "Stale",
        "Occupied", "Blocked", "Limit", "Placed", "Conflict", "Changed", "Removed", "MPCombatDeferred",
        "WrongDevice", "Empty", "Cooling", "NoTarget", "Fired", "Refilled", "Aimed", "NotCompared", "WrongBarrier", "BarrierRotated",
    ])
    keys.update("UI_OMHTT_Manage" + status for status in ['Drop', 'Hint', 'Head', 'Battery', 'Ammo', 'Modules', 'Module', 'Locked', 'ModulesHint', 'PowerNone', 'PowerExternal', 'PowerBattery', 'PowerDisabled', 'Stats', 'Timing', 'Fire', 'Unload', 'Queued', 'TransferMissing', 'TransferReach', 'UnloadFirst', 'TransferFavorite', 'TransferWrongItem', 'TransferFull', 'TransferCarried', 'TransferPending', 'NoHead', 'NoPower', 'Empty', 'Ready', 'Cooling', 'Reloading', 'NoTarget', 'Fired', 'Unavailable', 'MPCombatDeferred', 'WrongDevice'])
    keys.update("UI_OMHTT_Module" + name for name in ["Firing", "MotionDetection", "Filter", "Detection360"])
    keys.update("UI_OMHTT_Priority" + name for name in ["Closest", "Furthest", "Weakest", "Toughest"])
    keys.update(["UI_OMHTT_AutoOn", "UI_OMHTT_AutoOff"])
    for key in keys:
        assert key in translations, f"Missing translation: {key}"
    textures = list((PACKAGE / "42.20/media/textures").glob("*.png"))
    assert len(textures) == 38, "Existing technical markers plus turret inventory icon required"
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
            assert sprite.size == (128, 256) and sprite.mode == "RGBA"
            assert sprite.getbbox() is not None
            assert all(r == g == b for r, g, b, a in sprite.get_flattened_data() if a), "Sprite must remain white/grayscale"
    javac = Path(os.environ.get("PZ_JAVAC", "C:/Program Files/Java/jdk-17/bin/javac.exe"))
    run([javac, "-d", classes, ROOT / "tools/KahluaCheck.java"])
    run([javac, "-cp", GAME / "projectzomboid.jar", "-d", classes, ROOT / "tools/HybridAssetCheck.java"])
    model_log = run([GAME / "jre64/bin/java.exe", "--enable-native-access=ALL-UNNAMED",
        "-Djava.library.path=" + str(GAME), "-cp", os.pathsep.join([str(classes), str(GAME / "projectzomboid.jar")]),
        "HybridAssetCheck", PACKAGE / "42.20/media/models_X/OMHTT_ProbeHead.x"], cwd=GAME)
    (OUTPUT / "model-import.log").write_text(model_log, encoding="utf-8")
    stock = os.environ.get("OMHTT_STOCK_CLASSES") == "1"
    classpath = os.pathsep.join(str(path) for path in ([classes, GAME / "projectzomboid.jar", GAME] if stock else [classes, GAME, GAME / "projectzomboid.jar"]))
    log = run([GAME / "jre64/bin/java.exe", "--enable-native-access=ALL-UNNAMED", "-Djava.awt.headless=true",
        "-Duser.home=" + str(OUTPUT / "native-home"), "-cp", classpath, "KahluaCheck", ROOT], cwd=GAME)
    (OUTPUT / "validation.log").write_text(log, encoding="utf-8")
    files = {str(path.relative_to(PACKAGE)).replace("\\", "/"): hashlib.sha256(path.read_bytes()).hexdigest()
        for path in sorted(PACKAGE.rglob("*")) if path.is_file()}
    sources = [
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
    manifest = {"version": version, "gameRoot": str(GAME), "nativeClassOrder": "stock-jar-first" if stock else "installed-loose-first", "files": files, "gameEvidence": evidence,
        "inGameAcceptance": "pending", "nativeTableFormatVersion": 249}
    (OUTPUT / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(f"Package checks passed: {len(files)} files, {len(keys)} translation keys; manifest recorded.")


if __name__ == "__main__":
    main()
