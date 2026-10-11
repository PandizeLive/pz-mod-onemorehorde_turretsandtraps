import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MEDIA = ROOT / "Source/42.20/media"


def write(relative, content):
    (MEDIA / relative).write_bytes(content.replace("\r\n", "\n").encode("utf-8"))


def translations(category, values):
    path = MEDIA / f"lua/shared/Translate/EN/{category}.json"
    existing = json.loads(path.read_text(encoding="utf-8"))
    existing.update(values)
    path.write_bytes((json.dumps(existing, indent=4, ensure_ascii=False) + "\n").encode("utf-8"))


def main():
    modules = {"Firing": "Firing", "MotionDetection": "Detection", "Filter": "Filter",
               "RapidFire": "Rapid-Fire", "Velocity": "Velocity", "Range": "Range", "Capacity": "Medium Expansion Kit", "CapacitySmall": "Small Expansion Kit", "CapacityLarge": "Large Expansion Kit",
               "Detection360": "360", "Reload": "Reload", "Autoloader": "Autoloader"}
    item_types = {"CapacitySmall": "OMHTTModuleExpansionSmall", "Capacity": "OMHTTModuleExpansionMedium",
               "CapacityLarge": "OMHTTModuleExpansionLarge", "MotionDetection": "OMHTTModuleDetection", "Detection360": "OMHTTModule360"}
    items = """module Base {
    item OMHTTTurretBase {
        DisplayName = Turret Base,
        ItemType = base:container,
        DisplayCategory = Material,
        Weight = 6,
        WeightReduction = 0,
        Capacity = 28,
        Icon = OMHTT_TestCube,
        ScaleWorldIcon = 0.25,
        ConditionMax = 100,
        AcceptItemFunction = OMHTT_Turret.accept,
        Tooltip = Tooltip_OMHTT_TurretBase,
    }
    item OMHTTTurretPotato {
        DisplayName = Potato Launcher Head,
        WorldStaticModel = OMHTTTurretProbe,
        ItemType = base:normal,
        DisplayCategory = Material,
        Weight = 4,
        Icon = OMHTT_TestCube,
        ScaleWorldIcon = 0.25,
        ConditionMax = 100,
        Tooltip = Tooltip_OMHTT_PotatoHead,
    }
"""
    for key, name in modules.items():
        label = name if key.startswith("Capacity") else name + " Module"
        tooltip = "Capacity" if key.startswith("Capacity") else key
        definition = f"""    item {item_types.get(key, "OMHTTModule" + key)} {{
        DisplayName = {label},
        ItemType = base:normal,
        DisplayCategory = Material,
        Weight = 0.3,
        Icon = OMHTT_TestCube,
        ScaleWorldIcon = 0.25,
        Tooltip = Tooltip_OMHTT_Module{tooltip},
    }}
"""
        items += definition
    write("scripts/OMHTT_TurretItems.txt", items + "}\n")
    tools = ["item 1 tags[base:screwdriver] mode:keep flags[NoBrokenItems;DontRecordInput],",
             "item 1 [Base.Wrench;Base.PipeWrench] mode:keep flags[NoBrokenItems;DontRecordInput],"]
    base = {"MetalPipe": 2, "SmallSheetMetal": 2, "ScrapMetal": 1, "Screws": 8}
    head = {"MetalPipe": 1, "SmallSheetMetal": 1, "ScrapMetal": 2, "ElectronicsScrap": 2,
            "ElectricWire": 1, "TirePump": 1, "DuctTape": 2}
    recipes = "module Base {\n"
    names = {}
    for kind, label, materials, skills, xp, output, duration in [
        ("Base", "Craft Turret Base", base, "Mechanics:2", "Mechanics:15", "OMHTTTurretBase", 150),
        ("Head", "Craft Potato Launcher Head", head, "Mechanics:2;Electricity:1", "Mechanics:15;Electricity:5", "OMHTTTurretPotato", 200),
        ("HeadImprovised", "Craft Potato Launcher Head (Improvised)", {**head, "TirePump": 0, "ScrapMetal": 6}, "Mechanics:4;Electricity:1", "Mechanics:15;Electricity:5", "OMHTTTurretPotato", 250),
        ("Complete", "Craft Potato Turret", {k: base.get(k, 0) + head.get(k, 0) for k in base.keys() | head.keys()}, "Mechanics:2;Electricity:1", "Mechanics:30;Electricity:5", "OMHTTTurretBase", 350),
        ("CompleteImprovised", "Craft Potato Turret (Improvised)", {**{k: base.get(k, 0) + head.get(k, 0) for k in base.keys() | head.keys()}, "TirePump": 0, "ScrapMetal": 7}, "Mechanics:4;Electricity:1", "Mechanics:30;Electricity:5", "OMHTTTurretBase", 400),
    ]:
        name = "OMHTTCraftTurret" + kind
        names[name] = label
        inputs = list(tools)
        inputs += [f"item {amount} [Base.{material}]," for material, amount in sorted(materials.items()) if amount]
        recipes += f"""    craftRecipe {name} {{
        timedAction = Making,
        time = {duration},
        category = OMHTurrets,
        Tags = InHandCraft,
        needToBeLearn = false,
        SkillRequired = {skills},
        xpAward = {xp},
        Tooltip = UI_OMHTT_TurretDescription,
        OnAddToMenu = OMHTT_TurretMenuAvailable,
        OnTest = OMHTT_Turret.recipeInput,
        OnCreate = OMHTT_Turret.onCrafted,
        inputs {{
""" + "".join("            " + value + "\n" for value in inputs) + f"""        }}
        outputs {{
            item 1 Base.{output},
        }}
    }}
"""
    write("scripts/OMHTT_TurretRecipes.txt", recipes + "}\n")
    entity = """module Base {
    entity OMHTTDeployTurret {
        component UiConfig {
            xuiSkin = default,
            entityStyle = ES_OMHTTDeployTurret,
            uiEnabled = false,
        }
        component SpriteConfig {
            health = 100,
            skillBaseHealth = 0,
            bonusHealth = 0,
            isThumpable = true,
            breakSound = BreakObject,
            OnIsValid = OMHTT_TurretWorld.onIsValid,
            OnCreate = OMHTT_TurretWorld.onCreate,
"""
    for heading, index in zip("ENWS", range(16, 20)):
        entity += f"            face {heading} {{\n                layer {{\n                    row = omhtt_turret_01_{index},\n                }}\n            }}\n"
    entity += """        }
        component CraftRecipe {
            timedAction = BuildLowNoTool,
            time = 200,
            category = OMHTurrets,
            Tooltip = UI_OMHTT_DeployTurretDescription,
            needToBeLearn = false,
            OnAddToMenu = OMHTT_TurretMenuAvailable,
            OnTest = OMHTT_Turret.recipeInput,
            inputs {
                item 1 [Base.OMHTTTurretBase] flags[ItemCount],
            }
        }
    }
    xuiSkin default {
        entity ES_OMHTTDeployTurret {
            LuaWindowClass = ISEntityWindow,
            DisplayName = UI_OMHTT_DeployTurret,
            Icon = OMHTT_TestCube,
        }
    }
}
"""
    entity = entity.rstrip()[:-1]
    for group in range(4):
        entity += f"    entity OMHTTPotatoVisual{group} {{\n        component SpriteConfig {{\n"
        for facing, heading in enumerate("ENWS"):
            entity += f"            face {heading} {{\n                layer {{\n                    row = omhtt_turret_01_{group * 4 + facing},\n                }}\n            }}\n"
        entity += "        }\n    }\n"
    write("scripts/OMHTT_TurretConstruction.txt", entity + "}\n")
    texture = MEDIA / "textures/Item_OMHTT_TestCube.png"
    texture.write_bytes((MEDIA / "textures/OMHTT_TestCube.png").read_bytes())
    translations("Recipes", {**names, "OMHTTDeployTurret": "Deploy Turret"})
    translations("ItemName", {"Base.OMHTTTurretBase": "Turret Base", "Base.OMHTTTurretPotato": "Potato Launcher Head",
                              **{"Base." + item_types.get(k, "OMHTTModule" + k): (v if k.startswith("Capacity") else v + " Module") for k, v in modules.items()}})
    translations("Tooltip", {
        "Tooltip_OMHTT_TurretBase": "Holds a head, ammo, modules and a battery.",
        "Tooltip_OMHTT_PotatoHead": "Install in a turret base. Uses potatoes and power.",
        "Tooltip_OMHTT_ModuleFiring": "Fires on signal. Add Detection for automatic fire.",
        "Tooltip_OMHTT_ModuleMotionDetection": "Tracks zombies. Add Firing to shoot automatically.",
        "Tooltip_OMHTT_ModuleFilter": "Choose target priority in Manage.",
        "Tooltip_OMHTT_ModuleDetection360": "Unlocks all directions.",
        "Tooltip_OMHTT_ModuleRapidFire": "Increases fire rate. Stackable.",
        "Tooltip_OMHTT_ModuleReload": "Speeds up reloading. Stackable.",
        "Tooltip_OMHTT_ModuleAutoloader": "Eliminates reload time.",
        "Tooltip_OMHTT_ModuleVelocity": "Increases damage and knockdown chance. Stackable.",
        "Tooltip_OMHTT_ModuleRange": "Extends range. Stackable.",
        "Tooltip_OMHTT_ModuleCapacity": "Expands ammo and module storage.",
    })
    translations("UI", {
        "UI_OMHTT_Turret": "Turret", "UI_OMHTT_Manage": "Manage",
        "UI_OMHTT_Ready": "Ready", "UI_OMHTT_Reloading": "Reloading",
        "UI_OMHTT_TurretCycle": "Ammo: %1/%2 | Loaded: %3/%4",
        "UI_OMHTT_TurretLoadHint": "Drag supplies into the Turret loot container.",
        "UI_OMHTT_TurretBase": "Turret Base", "UI_OMHTT_PotatoTurret": "Potato Turret",
        "UI_OMHTT_DeployTurret": "Deploy Turret", "UI_OMHTT_NoHead": "None", "UI_OMHTT_None": "None",
        "UI_OMHTT_NoBattery": "None", "UI_OMHTT_NoPower": "No power.", "UI_OMHTT_NoHead": "No working head.",
        "UI_OMHTT_TurretContents": "Head: %1\nPotatoes: %2\nBattery: %3\nModules: %4",
        "UI_OMHTT_TotalWeight": "Total weight: %1",
        "UI_OMHTT_TurretDescription": "A modular defense. The potato head includes feeding and cycling. Needs potatoes and power.",
        "UI_OMHTT_DeployTurretDescription": "Place the selected turret with its contents. Pickup preserves supplies. Unload potatoes before removing the head.",
    })
    translations("ContextMenu", {"ContextMenu_OMHTT_TurretFire": "Fire", "ContextMenu_OMHTT_PickupTurret": "Pick up turret"})
    translations("IG_UI", {"IGUI_ContainerTitle_OMHTTTurret": "Turret", "IGUI_CraftingCategories_OMHTurrets": "OMH: Turrets", "IGUI_CraftingCategories_OMHTraps": "OMH: Traps"})
    options = [
        ("PotatoTurret", "boolean", "true", None, None, "Potato Turret", "Enable potato turrets."),
        ("PotatoRequirePower", "boolean", "true", None, None, "Require power", "Require electricity to fire."),
        ("PotatoAmmoCapacity", "integer", 100, 1, 500, "Ammo capacity", "Maximum potatoes."),
        ("PotatoModuleCapacity", "integer", 4, 0, 20, "Module storage", "Maximum stored modules."),
        ("PotatoHealth", "integer", 100, 1, 10000, "Durability", "Maximum durability of newly crafted bases."),
        ("PotatoDamage", "double", 50, 0, 1000, "Damage", "Direct-hit damage. 100 points = 1 health."),
        ("PotatoCooldown", "double", 0.5, 0.1, 60, "Shot cooldown", "Seconds between shots."),
        ("PotatoMagazineCapacity", "integer", 1, 1, 500, "Magazine size", "Loaded potatoes. Included in ammo capacity."),
        ("PotatoReloadTime", "double", 1, 0, 60, "Reload time", "Seconds to refill the magazine."),
        ("PotatoRange", "integer", 6, 1, 20, "Range", "Maximum firing distance in tiles."),
        ("PotatoKnockdownChance", "integer", 70, 0, 100, "Knockdown chance", "Percent chance on a standing target."),
        ("PotatoSplashPercent", "double", 25, 0, 100, "Splash damage percent", "Percent of direct damage. 0 disables."),
        ("PotatoSplashRadius", "double", 1.5, 0, 3, "Splash radius", "Splash distance in tiles."),
        ("PotatoBatteryPercentPerShot", "double", 0.1, 0, 100, "Battery use", "Battery charge percent per shot."),
        ("PotatoGeneratorFuelPerShot", "double", 0.001, 0, 1, "Generator use", "Extra generator fuel per shot."),
    ]
    sandbox = (MEDIA / "sandbox-options.txt").read_text(encoding="utf-8").split("\noption OMHTurretsTraps.PotatoTurret")[0].rstrip() + "\n\n"
    strings = {"Sandbox_OMHTurretsTraps_PotatoPage": "Turrets & Traps: Potato Turret"}
    for key, kind, default, minimum, maximum, label, tip in options:
        sandbox += f"option OMHTurretsTraps.{key} {{\n    type = {kind},\n    default = {default},\n"
        if minimum is not None:
            sandbox += f"    min = {minimum},\n    max = {maximum},\n"
        sandbox += f"    page = OMHTurretsTraps_PotatoPage,\n    translation = OMHTurretsTraps_{key},\n}}\n\n"
        strings["Sandbox_OMHTurretsTraps_" + key] = label
        strings["Sandbox_OMHTurretsTraps_" + key + "_tooltip"] = tip
    write("sandbox-options.txt", sandbox.rstrip() + "\n")
    translations("Sandbox", strings)


if __name__ == "__main__":
    main()
