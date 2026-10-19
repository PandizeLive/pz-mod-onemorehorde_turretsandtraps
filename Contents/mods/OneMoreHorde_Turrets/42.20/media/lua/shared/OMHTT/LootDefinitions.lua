local L = {}
L.POOLS = {"ElectronicStoreMisc", "CrateElectronics", "MechanicShelfElectric", "ArmyStorageElectronics",
    "ElectricianTools", "GunStoreAccessories", "ToolCabinetMechanics", "GarageTools", "CrateTools", "ToolStoreTools", "ToolStoreMisc", "MechanicShelfTools",
    "GarageMechanics", "CrateMechanics", "ElectronicStoreComputers", "ElectronicStoreHAMRadio"}
L.WEIGHTS = {Grid = 1, Siphon = 3, Lure = 14, Void = 1, Regulator = 5.5, Synergy = 1, Martyrdom = 1.5, Tack = 1.5, Conservation = 2.5, Piercing = 2.5, InitialBlow = 2.5, Execute = 2.5, Impact = 2.5, FiringEnhanced = 1.5, MotionDetectionEnhanced = 1.5, Magazine = 5, Splitter = 2.5, Fragment = 2.5, Firing = 30, MotionDetection = 30, Filter = 5, Detection360 = 2.5,
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
    if subset.Firing or subset.CapacityLarge then subset.Regulator = true end
    if subset.Firing then subset.Lure, subset.Grid = true, true end
    if subset.CapacityLarge then subset.Void = true end
    if subset.CapacityLarge then
        subset.FiringEnhanced, subset.MotionDetectionEnhanced = true, true
        subset.Siphon, subset.Synergy, subset.Martyrdom, subset.Tack = true, true, true, true
    end
end
L.DEFAULTS = {global = 1.011111111111111, items = {
    Grid = 1,
    Lure = 1, Void = 1,
    Firing = 0.4666666666666667,
    MotionDetection = 0.4666666666666667,
    Filter = 3.6,
    Detection360 = 4,
    Suppression = 4,
    RapidFire = 3.6,
    Reload = 4,
    Velocity = 2,
    Range = 3.6,
    CapacitySmall = 1.8666666666666667,
    Capacity = 2.4,
    CapacityLarge = 2,
    Autoloader = 0.6666666666666666,
    Critical = 4,
    Accuracy = 4,
    Magazine = 3.6,
    Splitter = 2.4,
    Fragment = 1.2,
    FiringEnhanced = 0.6666666666666666,
    MotionDetectionEnhanced = 0.6666666666666666,
    Piercing = 4,
    InitialBlow = 2.4,
    Execute = 1.2,
    Impact = 2.4,
    Conservation = 2.4,
    Siphon = 1, Synergy = 1,
    Martyrdom = 2,
    Tack = 2,
    Regulator = 3.6363636363636362
}}
return L
