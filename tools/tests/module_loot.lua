local L = require("OMHTT/ModuleLoot")
local settings = SandboxVars.OMHTurretsTraps
local savedItems = {}
for kind in pairs(L.WEIGHTS) do savedItems[kind] = settings["LootRate" .. kind]; settings["LootRate" .. kind] = 1 end
local originalGlobal, originalFilter = settings.ModuleLootRate, settings.LootRateFilter
local function count(pool, kind)
    local items = ProceduralDistributions.list[pool].items
    local found, weight = 0, 0
    for i = 1, #items, 2 do
        if items[i] == require("OMHTT/Turret").TYPES[kind] then found = found + 1; weight = items[i + 1] end
    end
    return found, weight
end
settings.Enabled, settings.PotatoTurret = true, true
settings.ModuleLootRate, settings.LootRateFilter = 1, 1
L.apply(); L.apply()
for i = 1, #L.POOLS do
    local pool = L.POOLS[i]
    for module, weight in pairs(L.WEIGHTS) do
        local found, actual = count(pool, module)
        local eligible = not L.SUBSETS[pool] or L.SUBSETS[pool][module]
        check(eligible and found == 1 and math.abs(actual - weight * L.SCALES[pool]) < 0.000001 or not eligible and found == 0, "Repeated loot merge respects pool-specific subsets")
    end

end
settings.ModuleLootRate, settings.LootRateFilter = 3, 2
L.apply()
local found, weight = count(L.POOLS[1], "Filter")
check(found == 1 and math.abs(weight - 27 * L.SCALES[L.POOLS[1]]) < 0.000001, "Global and per-module loot multipliers combine")
settings.LootRateFilter = 0; L.apply()
check(count(L.POOLS[1], "Filter") == 0 and count(L.POOLS[1], "Firing") == 1, "Zero only suppresses selected module")
settings.ModuleLootRate = 0; L.apply()
for module in pairs(L.WEIGHTS) do check(count(L.POOLS[1], module) == 0, "Global zero disables new module loot") end
check(ProceduralDistributions.list[L.POOLS[1]].items[1] == "BatteryBox", "Other mod and vanilla loot preserved")
settings.ModuleLootRate = 1
testMode = "server"; L.apply()
check(count(L.POOLS[1], "Firing") == 0, "Deferred multiplayer gets no unusable module loot")
testMode = "sp"
settings.ModuleLootRate, settings.LootRateFilter = originalGlobal, originalFilter

settings.ModuleLootRate = nil
for kind in pairs(L.WEIGHTS) do settings["LootRate" .. kind] = nil end
L.apply()
for kind, base in pairs(L.WEIGHTS) do
    local found, actual = count(L.POOLS[1], kind)
    check(found == 1 and math.abs(actual - base * L.SCALES[L.POOLS[1]] * L.DEFAULTS.global * L.DEFAULTS.items[kind]) < 0.000001, "Missing settings use the approved loot defaults")
    settings["LootRate" .. kind] = savedItems[kind]
end
settings.ModuleLootRate = originalGlobal

settings.ModuleLootMultiplier = 6
settings.LootFiring = 3
settings.ModuleLootRate, settings.LootRateFiring = nil, nil
L.apply()
local _, normalized = count(L.POOLS[1], "Firing")
check(math.abs(normalized - 27 * L.SCALES[L.POOLS[1]]) < 0.000001, "Legacy saved multipliers cannot double-apply normalized weights")
settings.ModuleLootMultiplier, settings.LootFiring = nil, nil
