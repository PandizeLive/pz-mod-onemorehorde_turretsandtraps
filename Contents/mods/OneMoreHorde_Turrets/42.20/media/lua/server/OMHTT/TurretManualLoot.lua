if isClient() then return end
require("Items/ProceduralDistributions")
local M = require("OMHTT/TurretManuals")
local L = require("OMHTT/ControlLootDefinitions")
local R = require("OMHTT/ControlRarity")

---@return nil
function M.applyLoot()
    local pools, seen, types = {}, {}, {}
    for i = 1, #L.POOLS do
        pools[#pools + 1] = L.POOLS[i]
        seen[L.POOLS[i]] = true
    end
    for i = 1, #M.literature do
        local name = M.literature[i]
        if not seen[name] then
            pools[#pools + 1] = name
            seen[name] = true
        end
    end
    for i = 1, #M.definitions do
        types[M.definitions[i].item] = true
    end
    local settings = SandboxVars.OMHTurretsTraps or {}
    local multiplier = settings.ModuleLootRate or L.DEFAULTS.global
    if settings.TurretsEnabled == false then
        multiplier = 0
    end
    R.refresh(settings)
    for i = 1, #pools do
        local name = pools[i]
        local pool = ProceduralDistributions.list[name]
        if pool and pool.items then
            for index = #pool.items - 1, 1, -2 do
                if types[pool.items[index]] then
                    table.remove(pool.items, index + 1)
                    table.remove(pool.items, index)
                end
            end
            for j = 1, #M.definitions do
                local manual = M.definitions[j]
                local weight = R.get(manual.key).weight * multiplier * (L.SCALES[name] or 1)
                if weight > 0 then
                    pool.items[#pool.items + 1] = manual.item
                    pool.items[#pool.items + 1] = weight
                end
            end
        end
    end
end

---@return nil
local function loaded()
    M.applyLoot()
    ItemPickerJava.Parse()
end

Events.OnLoadedTileDefinitions.Add(loaded)
return M
