if isClient() then return end
require("Items/ProceduralDistributions")
local M = require("OMHTT/TurretModules")
local D = require("OMHTT/Diagnostics")
local T = require("OMHTT/Turret")
local L = require("OMHTT/LootDefinitions")
local Pack = require("OMHTT/TurretModulePack")

---@return nil
function L.apply()
    local _, packTotal = Pack.pool()
    local multiplier = M.option("ModuleLootRate", L.DEFAULTS.global, 0, 20)
    if SandboxVars.OMHTurretsTraps.TurretsEnabled == false then
        multiplier = 0
    end
    D.emit("module-loot-summary", {pools = #L.POOLS, multiplier = multiplier}, nil, nil, "turrets")
    for i = 1, #L.POOLS do
        local name = L.POOLS[i]
        local pool = ProceduralDistributions.list[name]
        if pool and pool.items then
            local items = pool.items
            for index = #items - 1, 1, -2 do
                local module = T.component(items[index])
                if (module and L.WEIGHTS[module]) or items[index] == Pack.TYPE then
                    table.remove(items, index + 1)
                    table.remove(items, index)
                end
            end
            for module, weight in pairs(L.WEIGHTS) do
                local effective = weight * L.SCALES[name] * multiplier * M.option("LootRate" .. module, L.DEFAULTS.items[module], 0, 1000000)
                local subset = L.SUBSETS[name]
                if effective > 0 and (not subset or subset[module]) then
                    items[#items + 1] = T.TYPES[module]
                    items[#items + 1] = effective
                end
                D.trace("module-loot-weight", {pool = name, module = module, weight = effective}, "turrets")
            end
            local packWeight = M.option("PackLootWeight", 1, 0, 100) * L.SCALES[name] * multiplier
            if packWeight > 0 and packTotal > 0 then
                items[#items + 1] = Pack.TYPE
                items[#items + 1] = packWeight
            end
        else
            D.emit("module-loot-missing-pool", {pool = name}, nil, nil, "turrets")
        end
    end
end

---@return nil
function L.loaded()
    if isClient() then return end
    L.apply()
    ItemPickerJava.Parse()
end

Events.OnLoadedTileDefinitions.Add(L.loaded)
return L
