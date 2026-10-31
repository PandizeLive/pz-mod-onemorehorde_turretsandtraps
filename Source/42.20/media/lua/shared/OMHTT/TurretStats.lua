local G = require("OMHTT/Firearms")
local Class = require("OMHTT/FirearmClass")
local kits = {{"CapacityImprovised", "Improvised", 100, 2}, {"CapacitySmall", "Small", 200, 6}, {"Capacity", "", 400, 10}, {"CapacityLarge", "Large", 650, 14}}
local S = {}
local Stacking = require("OMHTT/TurretStacking")
local Heads = require("OMHTT/TurretHeads")

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
function S.bonus(active, name)
    return Stacking.bonus(active, name)
end

---@param active table Working expansion kits
---@return number slots Active capacity
function S.moduleCapacity(active)
    local extra = 0
    for i = 1, #kits do
        local kit = kits[i]
        if active[kit[1]] then extra = math.max(extra, S.option("Capacity" .. kit[2] .. "ModuleBonus", kit[4], 0, 20)) end
    end
    return math.floor(S.option("PotatoModuleCapacity", 2, 0, 20) + extra)
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
    local magazine = math.floor(S.option("PotatoMagazineCapacity", 3, 1, 500))
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
        ammoCapacity = S.option("FirearmAmmoCapacity", 250, 1, 500)
        accuracy = math.max(0, math.min(100, (gun:getHitChance() + gun:getAimingPerkHitChanceModifier()
            * S.option("FirearmAimingLevel", 3, 0, 10)) * S.option("FirearmAccuracyMultiplier", 1, 0, 3)))
        local precision = Class.precision(gun)
        farAccuracy = S.option(precision and "PrecisionRangeAccuracy" or "FirearmRangeAccuracy", precision and 80 or 60, 0, 100)
            * math.min(1, S.option("FirearmAccuracyMultiplier", 1, 0, 3))
        knockdown = 0
        critChance = gun:getCriticalChance()
        critMultiplier = gun:getCriticalDamageMultiplier() * S.option("CriticalDamageMultiplier", 1, 0, 5)
    end
    local head = Heads.get(gun)
    local rotary = head and head.rotary == true
    if head then
        damage, range, knockdown = head.damage, head.range, head.shove or 0
        accuracy, farAccuracy, critChance, critMultiplier = 100, 100, 0, 2
        cooldown, reload, magazine = .6, 0, 0
        if not rotary then
            cooldown, reload, magazine = head.cooldown, head.reload, head.magazine
            if head.key == "Ballista" then
                accuracy, farAccuracy = 75, 45
            end
            ammoCapacity = head.ammoCapacity or ammoCapacity
        end
    end
    farAccuracy = math.min(100, farAccuracy + S.bonus(active, "Accuracy"))
    accuracy = math.min(100, accuracy + S.bonus(active, "Accuracy"))
    critChance = math.min(100, critChance + S.bonus(active, "Critical"))
    local remaining = 1
    if (active.Suppression or 0) > 0 then
        remaining = (1 - S.option("SuppressionFirstReduction", 60, 0, 99) / 100)
            / (1 + S.option("SuppressionDiminishing", .6, 0, 10) * (active.Suppression - 1))
    end
    local ammoFamily = head and head.key or "Potato"
    if firearm then
        ammoFamily = gun:getProjectileCount() > 1 and "Shotgun" or "Firearm"
    elseif head and head.key == "Scrapshot" then
        ammoCapacity = 20
    end
    ammoCapacity = require("OMHTT/TurretAmmoCapacity").resolve(ammoFamily, active, ammoCapacity)
    local rapid = S.bonus(active, "RapidFire")
    local loading = S.bonus(active, "Reload")
    cooldown = cooldown / (1 + rapid / 100)
    rack = rack / (1 + rapid / 100)
    reload = reload / (1 + loading / 100)
    if active.Autoloader then reload = 0 end
    local firstMagazine, extraMagazine = Stacking.values("Magazine")
    if (active.Magazine or 0) > 0 then
        magazine = math.ceil(magazine + math.max(1, magazine * firstMagazine / 100)
            + (active.Magazine - 1) * math.max(1, magazine * extraMagazine / 100))
    end
    local enhancement = (firearm or head) and active.FiringEnhanced and S.option("EnhancedFireMultiplier", 4 / 3, 1, 5) or 1
    local splitter, fragment = active.Splitter or 0, active.Fragment or 0
    local execute, impact = active.Execute or 0, active.Impact or 0
    local knockBonus = S.bonus(active, "VelocityKnockdown")
    local weaponPower = math.max(1, math.sqrt(math.max(0, damage) / 80 * math.min(firearm and 50 or 30, range) / 15))
    local modulePower = 1 + (contents and contents.powerLoad or 0) * S.option("ModulePowerBonus", 5, 0, 200) / 5
    local effectPower = weaponPower * modulePower
    local regulator = 1 + S.bonus(active, "Regulator")
    local shotPower = S.option("PotatoBatteryPercentPerShot", 0.00045, 0, 100) * effectPower / regulator
    if firearm then shotPower = shotPower * S.option("FirearmBatteryMultiplier", 0.56, 0, 100) end
    local motorSpeed = 150 * (1 + rapid / 100) * enhancement
    local motorPower = 100 / S.option("RotaryBatteryHours", 128, .1, 200) * modulePower / regulator * motorSpeed / 150
    if head and head.key == "RotaryBlades" then
        motorPower = motorPower * S.option("RotaryBladesBatteryMultiplier", 1.33, 0, 100)
    end
    if head and head.key == "Lobber" then
        local payload = require("OMHTT/TurretAmmo").bombs[contents.payloadType]
        shotPower = (payload and payload.power or .02) * modulePower / regulator * (1 + S.bonus(active, "Velocity") / 100)
        shotPower = shotPower * S.option("LobberBatteryMultiplier", 0.65, 0, 100)
        shotPower = shotPower * math.max(1, (range + S.bonus(active, "Range")) / head.range) * (1 + splitter * .5)
    elseif head and head.key == "Scrapshot" then
        shotPower = S.option("ScrapshotBatteryPercent", 0.001, 0, 100) * modulePower / regulator * (1 + S.bonus(active, "Velocity") / 100) * (1 + splitter * .5)
            * math.max(1, (range + S.bonus(active, "Range")) / head.range)
    elseif head and head.key == "Arc" then
        shotPower = S.option("ArcBatteryPercent", 0.007, 0, 100) * modulePower / regulator
    elseif head and not rotary then
        shotPower = S.option("BallistaBatteryPercent", 0.01, 0, 100) * weaponPower / math.sqrt(4.8) * modulePower / regulator
    elseif rotary then
        shotPower = motorPower / 3600
        magazine = 0
    end
    return {fireSound = head and head.fireSound or (firearm and "OMHTTSuppressedM9Shoot" or "OMHTTPotatoFire"), ammoFree = head and head.ammoFree == true, arcTargets = math.floor(S.option("ArcTargets", 6, 1, 32)), arcJump = S.option("ArcJumpRange", 4, 1, 10), headKind = head and head.key, minimumRange = head and head.minimumRange or 0, cone = head and head.cone, rotary = rotary, motorSpeed = motorSpeed, motorPower = motorPower,
        damage = damage * (1 + S.bonus(active, "Velocity") / 100),
        knockdown = math.min(100, knockdown + knockBonus),
        range = range + S.bonus(active, "Range"),
        ammo = math.floor(ammoCapacity),
        modules = S.moduleCapacity(active),
        conservation = 1 + S.bonus(active, "Conservation"),
        synergy = active.Synergy ~= nil,
        siphon = S.bonus(active, "Siphon"),
        martyrdom = S.bonus(active, "Martyrdom"),
        martyrdomDamage = S.option("MartyrdomDamage", 20, 0, 1000),
        tack = S.bonus(active, "Tack"),
        tackDamage = S.option("TackDamage", 10, 0, 1000),
        tackLifetime = S.option("TackLifetime", 10, 1, 60) * 1000,
        splitter = splitter, fragment = fragment, splitterDamage = S.option("SplitterDamage", 50, 0, 100) / 100,
        piercing = (active.Piercing or 0) > 0 and not rotary and (not head or head.key ~= "Lobber") and active.Piercing or 0,
        pierceRetention = S.option("PiercingRetention", 70, 0, 100) / 100,
        initialBlow = S.bonus(active, "InitialBlow") / 100,
        initialThreshold = S.option("InitialBlowThreshold", 90, 0, 100) / 100,
        execute = math.min(100, S.bonus(active, "Execute")) / 100,
        impact = math.min(100, S.bonus(active, "Impact")),
        fragmentDamage = S.bonus(active, "Fragment") / 100,
        fragmentRange = S.option("FragmentRange", 4, 1, 10),
        effectPower = effectPower, weaponPower = weaponPower, modulePower = modulePower,
        regulator = regulator,
        batteryPercent = shotPower,
        generatorFuel = S.option("PotatoGeneratorFuelPerShot", 0.0001, 0, 1) * effectPower,
        magazine = magazine, accuracy = accuracy, farAccuracy = farAccuracy, critChance = critChance, critMultiplier = critMultiplier, rack = rack * 1000 / enhancement, firearm = firearm ~= nil,
        suppressed = (active.Suppression or 0) > 0,
        hearingMultiplier = remaining,
        reload = reload * 1000, cooldown = rotary and 90000 / motorSpeed or math.max(cooldown, firearm and gun:isRackAfterShoot() and rack or 0) * 1000 / enhancement,
        autoloader = active.Autoloader ~= nil}
end

---@param head HandWeapon Mounted head
---@param stats table Effective stats
---@return number radius Zombie hearing tiles
---@nodiscard
function S.hearingRadius(head, stats)
    local radius = S.option("PotatoHearingRadius", 8, 0, 200)
    if stats.firearm then
        radius = head:getSoundRadius()
    elseif stats.headKind then
        local configured = S.option(stats.headKind .. "HearingRadius", -1, -1, 200)
        if configured >= 0 then
            radius = configured
        end
    end
    return math.ceil(radius * stats.hearingMultiplier)
end

return S
