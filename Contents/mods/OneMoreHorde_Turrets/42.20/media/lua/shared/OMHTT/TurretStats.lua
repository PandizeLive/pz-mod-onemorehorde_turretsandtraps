local G = require("OMHTT/Firearms")
local Class = require("OMHTT/FirearmClass")
local kits = {{"CapacityImprovised", "Improvised", 100, 2}, {"CapacitySmall", "Small", 200, 6}, {"Capacity", "", 400, 10}, {"CapacityLarge", "Large", 650, 14}}
local S = {}
S.POWER_WEIGHTS = {Firing = 1, FiringImprovised = 1, FiringEnhanced = 1, MotionDetection = 1, MotionDetectionImprovised = 1, MotionDetectionEnhanced = 1, Filter = 1, Detection360 = 1, RapidFire = 1, Reload = 1, Velocity = 1, Range = 1, Critical = 1, Accuracy = 1, Suppression = 1, Autoloader = 1, Magazine = 1, Splitter = 1, Fragment = 1, Piercing = 1, InitialBlow = 1, Execute = 1, Impact = 1}

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

---@param gun HandWeapon Mounted firearm
---@return boolean automatic Native Auto capability
---@nodiscard
function S.automatic(gun)
    if gun:getFireMode() == "Auto" then return true end
    local modes = gun.getFireModePossibilities and gun:getFireModePossibilities()
    if modes then
        for i = 0, modes:size() - 1 do
            if modes:get(i) == "Auto" then return true end
        end
    end
    return false
end

---@param contents table? Installed inventory snapshot
---@return table stats
function S.resolve(contents)
    local active = contents and contents.active or {}
    local cooldown = S.option("PotatoCooldown", 2, 0.1, 60)
    local reload = S.option("PotatoReloadTime", 2, 0, 60)
    local damage = S.option("PotatoDamage", 35, 0, 1000)
    local knockdown = S.option("PotatoKnockdownChance", 40, 0, 100)
    local range = S.option("PotatoRange", 6, 1, 20)
    local gun = contents and contents.head
    local firearm = G.profile(gun)
    local magazine = math.floor(S.option("PotatoMagazineCapacity", 1, 1, 500))
    local ammoCapacity = S.option("PotatoAmmoCapacity", 100, 1, 500)
    local accuracy, rack = 100, 0
    local farAccuracy = 100
    local critChance, critMultiplier = S.option("PotatoCriticalChance", 0, 0, 100), S.option("PotatoCriticalDamage", 2, 1, 20)
    if firearm then
        damage = (gun:getMinDamage() + gun:getMaxDamage()) * 50 * S.option("FirearmDamageMultiplier", 1, 0, 5)
        range = gun:getMaxRange() * S.option("FirearmRangeMultiplier", 1, 0.1, 3)
        cooldown = math.max(0.1, gun:getRecoilDelay() / 30)
        if S.automatic(gun) then
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
        local precision = Class.precision(gun)
        farAccuracy = S.option(precision and "PrecisionRangeAccuracy" or "FirearmRangeAccuracy", precision and 80 or 60, 0, 100)
            * math.min(1, S.option("FirearmAccuracyMultiplier", 1, 0, 3))
        knockdown = 0
        critChance = gun:getCriticalChance()
        critMultiplier = gun:getCriticalDamageMultiplier() * S.option("CriticalDamageMultiplier", 1, 0, 5)
    end
    farAccuracy = math.min(100, farAccuracy + (active.Accuracy or 0) * S.option("AccuracyBonus", 5, 0, 100))
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
            extraAmmo = math.max(extraAmmo, S.option("Capacity" .. kit[2] .. "AmmoBonus", kit[3], 0, 2000))
            extraModules = math.max(extraModules, S.option("Capacity" .. kit[2] .. "ModuleBonus", kit[4], 0, 20))
        end
    end
    local rapid = S.bonus(active, "RapidFire", 25, 200)
    local loading = S.bonus(active, "Reload", 25, 200)
    cooldown = math.min(cooldown, math.max(math.min(cooldown, S.option("RapidFireMinimum", 0.25, 0.1, 10)), cooldown / (1 + rapid / 100)))
    rack = math.max(0.1, rack / (1 + rapid / 100))
    reload = math.min(reload, math.max(S.option("ReloadMinimum", 0.25, 0, 10), reload / (1 + loading / 100)))
    if active.Autoloader then reload = 0 end
    magazine = math.ceil(magazine + (active.Magazine or 0) * math.max(1, magazine * S.option("MagazineBonus", 35, 0, 200) / 100))
    local enhancement = firearm and active.FiringEnhanced and S.option("EnhancedFireMultiplier", 4 / 3, 1, 5) or 1
    local splitter, fragment = active.Splitter or 0, active.Fragment or 0
    local execute, impact = active.Execute or 0, active.Impact or 0
    local knockBonus = math.min((active.Velocity or 0) * S.option("VelocityKnockdownBonus", 5, 0, 100),
        math.max(0, S.option("VelocityKnockdownCap", 90, 0, 100) - knockdown))
    local weaponPower = math.max(1, math.sqrt(math.max(0, damage) / 80 * math.min(firearm and 50 or 30, range) / 15))
    local modulePower = 1 + (contents and contents.powerLoad or 0) * S.option("ModulePowerBonus", 5, 0, 200) / 100
    local effectPower = weaponPower * modulePower
    return {damage = damage * (1 + S.bonus(active, "Velocity", 20, 100) / 100),
        knockdown = math.min(100, knockdown + knockBonus),
        range = math.min(firearm and 50 or 30, range + S.bonus(active, "Range", 2, 10)),
        ammo = math.floor(ammoCapacity + extraAmmo),
        modules = math.floor(S.option("PotatoModuleCapacity", 2, 0, 20) + extraModules),
        splitter = splitter, fragment = fragment, splitterDamage = S.option("SplitterDamage", 50, 0, 100) / 100,
        piercing = (active.Piercing or 0) > 0 and firearm and gun:getProjectileCount() <= 1 and active.Piercing or 0,
        pierceRetention = S.option("PiercingRetention", 70, 0, 100) / 100,
        initialBlow = (active.InitialBlow or 0) * S.option("InitialBlowBonus", 25, 0, 200) / 100,
        initialThreshold = S.option("InitialBlowThreshold", 90, 0, 100) / 100,
        execute = execute > 0 and (S.option("ExecuteFirst", 10, 0, 100) + (execute - 1) * S.option("ExecuteBonus", 2, 0, 100)) / 100 or 0,
        impact = impact > 0 and math.min(100, S.option("ImpactFirst", 60, 0, 100) + (impact - 1) * S.option("ImpactBonus", 2, 0, 100)) or 0,
        fragmentDamage = math.min(S.option("FragmentDamageCap", 40, 0, 100), S.option("FragmentDamage", 20, 0, 100) + math.max(0, fragment - 1) * S.option("FragmentBonus", 5, 0, 100)) / 100,
        fragmentRange = S.option("FragmentRange", 4, 1, 10),
        effectPower = effectPower, weaponPower = weaponPower, modulePower = modulePower,
        batteryPercent = S.option("PotatoBatteryPercentPerShot", 0.005, 0, 100) * effectPower,
        generatorFuel = S.option("PotatoGeneratorFuelPerShot", 0.0001, 0, 1) * effectPower,
        magazine = magazine, accuracy = accuracy, farAccuracy = farAccuracy, critChance = critChance, critMultiplier = critMultiplier, rack = rack * 1000 / enhancement, firearm = firearm ~= nil,
        suppressed = (active.Suppression or 0) > 0,
        hearingMultiplier = remaining,
        reload = reload * 1000, cooldown = math.max(cooldown, firearm and gun:isRackAfterShoot() and rack or 0) * 1000 / enhancement,
        autoloader = active.Autoloader ~= nil}
end

---@param head HandWeapon Mounted head
---@param stats table Effective stats
---@return number radius Zombie hearing tiles
---@nodiscard
function S.hearingRadius(head, stats)
    local radius = S.option("PotatoHearingRadius", 8, 0, 200)
    if stats.firearm then radius = head:getSoundRadius() end
    return math.ceil(radius * stats.hearingMultiplier)
end

return S
