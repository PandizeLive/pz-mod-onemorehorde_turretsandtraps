local G = require("OMHTT/Firearms")
local kits = {{"CapacitySmall", "Small", 50, 2}, {"Capacity", "", 100, 4}, {"CapacityLarge", "Large", 200, 6}}
local S = {}

---@param key string Setting
---@param fallback number Default
---@param minimum number Minimum
---@param maximum number Maximum
---@return number value
---@nodiscard
function S.option(key, fallback, minimum, maximum)
    local settings = SandboxVars.OMHTurretsTraps
    local value = settings and settings[key]
    if type(value) ~= "number" or value ~= value then return fallback end
    return math.max(minimum, math.min(maximum, value))
end

---@param active table Working modules
---@param name string Module
---@param gain number Per-copy default
---@param cap number Maximum default
---@return number bonus
---@nodiscard
function S.bonus(active, name, gain, cap)
    return math.min((active[name] or 0) * S.option(name .. "Bonus", gain, 0, 200),
        S.option(name .. "BonusCap", cap, 0, 1000))
end

---@param contents table? Inventory summary
---@return table stats Effective values, times in milliseconds
---@nodiscard
function S.resolve(contents)
    local active = contents and contents.active or {}
    local cooldown = S.option("PotatoCooldown", 2, 0.1, 60)
    local reload = S.option("PotatoReloadTime", 2, 0, 60)
    local damage = S.option("PotatoDamage", 35, 0, 1000)
    local knockdown = S.option("PotatoKnockdownChance", 70, 0, 100)
    local range = S.option("PotatoRange", 6, 1, 20)
    local gun = contents and contents.head
    local firearm = G.profile(gun)
    local magazine = math.floor(S.option("PotatoMagazineCapacity", 1, 1, 500))
    local ammoCapacity = S.option("PotatoAmmoCapacity", 100, 1, 500)
    local accuracy, rack = 100, 0
    local critChance, critMultiplier = S.option("PotatoCriticalChance", 0, 0, 100), S.option("PotatoCriticalDamage", 2, 1, 20)
    if firearm then
        damage = (gun:getMinDamage() + gun:getMaxDamage()) * 50 * S.option("FirearmDamageMultiplier", 1, 0, 5)
        range = gun:getMaxRange() * S.option("FirearmRangeMultiplier", 1, 0.1, 3)
        cooldown = math.max(0.1, gun:getRecoilDelay() / 30)
        if gun:getFireMode() == "Auto" then
            local cyclic = gun:getCyclicRateMultiplier()
            if cyclic <= 0 then cyclic = 1 end
            cooldown = (1 / 3) / (1.5 * cyclic)
        end
        if gun:isRackAfterShoot() then cooldown = math.max(cooldown, firearm.rack) end
        local rate = S.option("FirearmRateMultiplier", 0.75, 0.1, 5)
        cooldown = cooldown / rate
        reload = firearm.reload * S.option("FirearmReloadMultiplier", 1, 0, 5)
        rack = firearm.rack * S.option("FirearmCycleMultiplier", 1, 0.1, 5) / rate
        magazine = gun:getMaxAmmo()
        ammoCapacity = S.option("FirearmAmmoCapacity", 100, 1, 500)
        accuracy = math.max(0, math.min(100, (gun:getHitChance() + gun:getAimingPerkHitChanceModifier()
            * S.option("FirearmAimingLevel", 3, 0, 10)) * S.option("FirearmAccuracyMultiplier", 1, 0, 3)))
        knockdown = 0
        critChance = gun:getCriticalChance()
        critMultiplier = gun:getCriticalDamageMultiplier() * S.option("CriticalDamageMultiplier", 1, 0, 5)
    end
    accuracy = math.min(100, accuracy + (active.Accuracy or 0) * S.option("AccuracyBonus", 5, 0, 100))
    critChance = math.min(100, critChance + (active.Critical or 0) * S.option("CriticalBonus", 5, 0, 100))
    local remaining = 1
    if (active.Suppression or 0) > 0 then
        remaining = (1 - S.option("SuppressionFirstReduction", 60, 0, 99) / 100)
            / (1 + S.option("SuppressionDiminishing", .6, 0, 10) * (active.Suppression - 1))
    end
    local extraAmmo, extraModules = 0, 0
    for i = 1, #kits do
        local kit = kits[i]
        if active[kit[1]] then
            extraAmmo = math.max(extraAmmo, S.option("Capacity" .. kit[2] .. "AmmoBonus", kit[3], 0, 500))
            extraModules = math.max(extraModules, S.option("Capacity" .. kit[2] .. "ModuleBonus", kit[4], 0, 20))
        end
    end
    local rapid = S.bonus(active, "RapidFire", 25, 200)
    local loading = S.bonus(active, "Reload", 25, 200)
    cooldown = math.min(cooldown, math.max(math.min(cooldown, S.option("RapidFireMinimum", 0.25, 0.1, 10)), cooldown / (1 + rapid / 100)))
    rack = math.max(0.1, rack / (1 + rapid / 100))
    reload = math.min(reload, math.max(S.option("ReloadMinimum", 0.25, 0, 10), reload / (1 + loading / 100)))
    if active.Autoloader then reload = 0 end
    local knockBonus = math.min((active.Velocity or 0) * S.option("VelocityKnockdownBonus", 5, 0, 100),
        math.max(0, S.option("VelocityKnockdownCap", 90, 0, 100) - knockdown))
    return {damage = damage * (1 + S.bonus(active, "Velocity", 20, 100) / 100),
        knockdown = math.min(100, knockdown + knockBonus),
        range = math.min(firearm and 50 or 30, range + S.bonus(active, "Range", 2, 10)),
        ammo = math.floor(ammoCapacity + extraAmmo),
        modules = math.floor(S.option("PotatoModuleCapacity", 4, 0, 20) + extraModules),
        magazine = magazine, accuracy = accuracy, critChance = critChance, critMultiplier = critMultiplier, rack = rack * 1000, firearm = firearm ~= nil,
        suppressed = (active.Suppression or 0) > 0,
        hearingMultiplier = remaining,
        reload = reload * 1000, cooldown = math.max(cooldown, firearm and gun:isRackAfterShoot() and rack or 0) * 1000,
        autoloader = active.Autoloader ~= nil}
end

return S
