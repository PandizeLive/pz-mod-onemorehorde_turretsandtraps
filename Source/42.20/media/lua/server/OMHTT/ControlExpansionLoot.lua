if isClient() then return end
require("Items/ProceduralDistributions")
local L = require("OMHTT/ControlLootDefinitions")
local E = require("OMHTT/ControlExpansion")
local types = {CapacitySmall = "Base.OMHTTModuleExpansionSmall", Capacity = "Base.OMHTTModuleExpansionMedium", CapacityLarge = "Base.OMHTTModuleExpansionLarge"}
local Loot = {}

---@return nil
function Loot.loaded()
    if ScriptManager.instance:FindItem("Base.OMHTTTurretBase") then return end
    local multiplier = E.option("ModuleLootRate", L.DEFAULTS.global, 20)
    for i = 1, #L.POOLS do
        local name = L.POOLS[i]
        local pool = ProceduralDistributions.list[name]
        if pool and pool.items then
            local items = pool.items
            for index = #items - 1, 1, -2 do
                for _, fullType in pairs(types) do
                    if items[index] == fullType then
                        table.remove(items, index + 1)
                        table.remove(items, index)
                        break
                    end
                end
            end
            for component, fullType in pairs(types) do
                local weight = L.WEIGHTS[component] * L.SCALES[name] * multiplier * E.option("LootRate" .. component, L.DEFAULTS.items[component], 20)
                if weight > 0 and (not L.SUBSETS[name] or L.SUBSETS[name][component]) then
                    items[#items + 1], items[#items + 2] = fullType, weight
                end
            end
        end
    end
    ItemPickerJava.Parse()
end
Events.OnLoadedTileDefinitions.Add(Loot.loaded)
return Loot
