local L = {}
L.POOLS = {"ElectronicStoreMisc", "CrateElectronics", "MechanicShelfElectric", "ArmyStorageElectronics",
    "ElectricianTools", "GunStoreAccessories", "ToolCabinetMechanics", "GarageTools", "CrateTools", "ToolStoreTools", "ToolStoreMisc", "MechanicShelfTools",
    "GarageMechanics", "CrateMechanics", "ElectronicStoreComputers", "ElectronicStoreHAMRadio"}
L.WEIGHTS = {Conservation = 2.5, Piercing = 2.5, InitialBlow = 2.5, Execute = 2.5, Impact = 2.5, FiringEnhanced = 1.5, MotionDetectionEnhanced = 1.5, Magazine = 5, Splitter = 2.5, Fragment = 2.5, Firing = 30, MotionDetection = 30, Filter = 5, Detection360 = 2.5,
    Suppression = 2.5, Critical = 2.5, Accuracy = 5, RapidFire = 5, Reload = 5,
    Velocity = 5, Range = 5, CapacitySmall = 7.5, Capacity = 2.5, CapacityLarge = 1.5, Autoloader = 1.5}
L.SUBSETS = {
    ElectricianTools = {Firing = true, MotionDetection = true, Filter = true, Detection360 = true},
    GunStoreAccessories = {Conservation = true, Piercing = true, InitialBlow = true, Execute = true, Impact = true, Magazine = true, Splitter = true, Fragment = true, Suppression = true, Range = true, Velocity = true, Accuracy = true, Critical = true},
    ToolCabinetMechanics = {Magazine = true, Reload = true, RapidFire = true, CapacitySmall = true, Capacity = true, CapacityLarge = true, Autoloader = true},
}
L.SCALES = {ElectronicStoreMisc = 0.35, CrateElectronics = 1, MechanicShelfElectric = 0.35,
    ArmyStorageElectronics = 1, ElectricianTools = 0.5, GunStoreAccessories = 1, ToolCabinetMechanics = 1,
    GarageTools = 0.3, CrateTools = 0.45, ToolStoreTools = 0.4, ToolStoreMisc = 0.4, MechanicShelfTools = 0.4,
    GarageMechanics = 0.3, CrateMechanics = 0.45, ElectronicStoreComputers = 0.35, ElectronicStoreHAMRadio = 0.35}
L.SUBSETS.GarageTools = {Firing = true, MotionDetection = true, Reload = true, RapidFire = true, CapacitySmall = true}
L.SUBSETS.CrateTools = {Firing = true, MotionDetection = true, Reload = true, RapidFire = true, CapacitySmall = true, Capacity = true}
L.SUBSETS.ToolStoreTools = L.SUBSETS.CrateTools
L.SUBSETS.ToolStoreMisc = L.SUBSETS.ElectricianTools
L.SUBSETS.MechanicShelfTools = L.SUBSETS.ToolCabinetMechanics
L.SUBSETS.GarageMechanics = L.SUBSETS.GarageTools
L.SUBSETS.CrateMechanics = L.SUBSETS.CrateTools
L.SUBSETS.ElectronicStoreComputers = L.SUBSETS.ElectricianTools
L.SUBSETS.ElectronicStoreHAMRadio = L.SUBSETS.ElectricianTools
for _, subset in pairs(L.SUBSETS) do
    if subset.CapacityLarge then subset.FiringEnhanced, subset.MotionDetectionEnhanced = true, true end
end
L.DEFAULTS = {global = 1, items = {Conservation = 1, Piercing = 1, InitialBlow = 1, Execute = 1, Impact = 1, FiringEnhanced = 1, MotionDetectionEnhanced = 1, Magazine = 1, Splitter = 1, Fragment = 1,
    Firing = 1, MotionDetection = 1, Filter = 1, Detection360 = 1, Suppression = 1, RapidFire = 1, Reload = 1, Velocity = 1, Range = 1, CapacitySmall = 1, Capacity = 1, CapacityLarge = 1, Autoloader = 1, Critical = 1, Accuracy = 1
}}
return L
