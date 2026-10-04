local L = {}
L.POOLS = {"ElectronicStoreMisc", "CrateElectronics", "MechanicShelfElectric", "ArmyStorageElectronics",
    "ElectricianTools", "GunStoreAccessories", "ToolCabinetMechanics", "GarageTools", "CrateTools", "ToolStoreTools", "ToolStoreMisc", "MechanicShelfTools"}
L.WEIGHTS = {Firing = 27, MotionDetection = 27, Filter = 4.5, Detection360 = 2.25,
    Suppression = 2.25, Critical = 2.25, Accuracy = 4.5, RapidFire = 4.5, Reload = 4.5,
    Velocity = 4.5, Range = 4.5, CapacitySmall = 6.75, Capacity = 2.25, CapacityLarge = 1.35, Autoloader = 1.35}
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
L.DEFAULTS = {global = 1, items = {
    Firing = 1, MotionDetection = 1, Filter = 1, Detection360 = 1, Suppression = 1, RapidFire = 1, Reload = 1, Velocity = 1, Range = 1, CapacitySmall = 1, Capacity = 1, CapacityLarge = 1, Autoloader = 1, Critical = 1, Accuracy = 1
}}
return L
