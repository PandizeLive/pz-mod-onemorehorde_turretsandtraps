local L = {}
L.POOLS = {"ElectronicStoreMisc", "CrateElectronics", "MechanicShelfElectric", "ArmyStorageElectronics",
    "ElectricianTools", "GunStoreAccessories", "ToolCabinetMechanics", "GarageTools", "CrateTools", "ToolStoreTools", "ToolStoreMisc", "MechanicShelfTools"}
L.WEIGHTS = {Firing = 2, MotionDetection = 2, Filter = 0.5, Detection360 = 0.25,
    Suppression = 0.25, Critical = 0.25, Accuracy = 0.5, RapidFire = 0.5, Reload = 0.5,
    Velocity = 0.5, Range = 0.5, CapacitySmall = 0.5, Capacity = 0.25, CapacityLarge = 0.1, Autoloader = 0.1}
L.SUBSETS = {
    ElectricianTools = {Firing = true, MotionDetection = true, Filter = true, Detection360 = true},
    GunStoreAccessories = {Suppression = true, Range = true, Velocity = true, Accuracy = true, Critical = true},
    ToolCabinetMechanics = {Reload = true, RapidFire = true, CapacitySmall = true, Capacity = true, CapacityLarge = true, Autoloader = true},
}
L.SCALES = {ElectronicStoreMisc = 0.35, CrateElectronics = 1, MechanicShelfElectric = 0.35,
    ArmyStorageElectronics = 1, ElectricianTools = 0.5, GunStoreAccessories = 1, ToolCabinetMechanics = 1,
    GarageTools = 0.3, CrateTools = 0.45, ToolStoreTools = 0.4, ToolStoreMisc = 0.4, MechanicShelfTools = 0.4}
L.SUBSETS.GarageTools = {Firing = true, MotionDetection = true, Reload = true, RapidFire = true, CapacitySmall = true}
L.SUBSETS.CrateTools = {Firing = true, MotionDetection = true, Reload = true, RapidFire = true, CapacitySmall = true, Capacity = true}
L.SUBSETS.ToolStoreTools = L.SUBSETS.CrateTools
L.SUBSETS.ToolStoreMisc = L.SUBSETS.ElectricianTools
L.SUBSETS.MechanicShelfTools = L.SUBSETS.ToolCabinetMechanics
L.DEFAULTS = {global = 6, items = {
    Firing = 3, MotionDetection = 3, Filter = 2, Detection360 = 2, Suppression = 2, RapidFire = 2, Reload = 2, Velocity = 2, Range = 2, CapacitySmall = 3, Capacity = 2, CapacityLarge = 3, Autoloader = 3, Critical = 2, Accuracy = 2
}}
return L
