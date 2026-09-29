LuaEventManager.AddEvent("OnLoadedTileDefinitions")
ProceduralDistributions = {list = {}}
for _, name in pairs({"ElectronicStoreMisc", "CrateElectronics", "MechanicShelfElectric", "ArmyStorageElectronics"}) do
    ProceduralDistributions.list[name] = {items = {"BatteryBox", 20}}
end
