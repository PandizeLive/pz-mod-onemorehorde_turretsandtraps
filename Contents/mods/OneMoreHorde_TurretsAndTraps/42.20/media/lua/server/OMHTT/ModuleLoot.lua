if isClient() then return end
require("Items/ProceduralDistributions")
local M = require("OMHTT/TurretModules")
local D = require("OMHTT/Diagnostics")
local T = require("OMHTT/Turret")
local L = {}
L.POOLS = {"ElectronicStoreMisc", "CrateElectronics", "MechanicShelfElectric", "ArmyStorageElectronics"}
L.WEIGHTS = {Firing = 2, MotionDetection = 2, Filter = 0.5, Detection360 = 0.25,
    RapidFire = 0.5, Reload = 0.5, Velocity = 0.5, Range = 0.5, CapacitySmall = 0.5, Capacity = 0.25, CapacityLarge = 0.1, Autoloader = 0.1}

---@return nil
function L.apply()
    local multiplier = M.option("ModuleLootMultiplier", 1, 0, 20)
    if isServer() or SandboxVars.OMHTurretsTraps.Enabled == false or SandboxVars.OMHTurretsTraps.PotatoTurret == false then
        multiplier = 0
    end
    for i = 1, #L.POOLS do
        local name = L.POOLS[i]
        local pool = ProceduralDistributions.list[name]
        if pool and pool.items then
            local items = pool.items
            for index = #items - 1, 1, -2 do
                local module = T.component(items[index])
                if module and L.WEIGHTS[module] then
                    table.remove(items, index + 1)
                    table.remove(items, index)
                end
            end
            for module, weight in pairs(L.WEIGHTS) do
                local effective = weight * multiplier * M.option("Loot" .. module, 1, 0, 20)
                if effective > 0 then
                    items[#items + 1] = T.TYPES[module]
                    items[#items + 1] = effective
                end
                D.emit("module-loot-weight", {pool = name, module = module, weight = effective})
            end
        else
            D.emit("module-loot-missing-pool", {pool = name})
        end
    end
end

---@return nil
function L.loaded()
    if isServer() then return end
    L.apply()
    ItemPickerJava.Parse()
end

Events.OnLoadedTileDefinitions.Add(L.loaded)
return L
