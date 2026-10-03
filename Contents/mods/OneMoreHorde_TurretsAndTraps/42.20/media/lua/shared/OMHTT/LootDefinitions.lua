local L = {}
L.POOLS = {"ElectronicStoreMisc", "CrateElectronics", "MechanicShelfElectric", "ArmyStorageElectronics",
    "ElectricianTools", "GunStoreAccessories", "ToolCabinetMechanics"}
L.WEIGHTS = {Firing = 2, MotionDetection = 2, Filter = 0.5, Detection360 = 0.25,
    Suppression = 0.25, Critical = 0.25, Accuracy = 0.5, RapidFire = 0.5, Reload = 0.5,
    Velocity = 0.5, Range = 0.5, CapacitySmall = 0.5, Capacity = 0.25, CapacityLarge = 0.1, Autoloader = 0.1}
L.SUBSETS = {
    ElectricianTools = {Firing = true, MotionDetection = true, Filter = true, Detection360 = true},
    GunStoreAccessories = {Suppression = true, Range = true, Velocity = true, Accuracy = true, Critical = true},
    ToolCabinetMechanics = {Reload = true, RapidFire = true, CapacitySmall = true, Capacity = true, CapacityLarge = true, Autoloader = true},
}
L.DEFAULTS = {global = 6, items = {
    Firing = 3, MotionDetection = 3, Filter = 2, Detection360 = 2, Suppression = 2, RapidFire = 2, Reload = 2, Velocity = 2, Range = 2, CapacitySmall = 3, Capacity = 2, CapacityLarge = 3, Autoloader = 3, Critical = 2, Accuracy = 2
}}
return L
