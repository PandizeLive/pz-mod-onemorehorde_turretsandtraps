LuaEventManager.AddEvent("OnLoadedTileDefinitions")
ProceduralDistributions = {list = {}}
for _, name in pairs(require("OMHTT/LootDefinitions").POOLS) do
    ProceduralDistributions.list[name] = {items = {"BatteryBox", 20}}
end
