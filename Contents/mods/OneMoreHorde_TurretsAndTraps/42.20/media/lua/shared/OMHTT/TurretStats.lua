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
    local capacity = active.Capacity and 1 or 0
    local rapid = S.bonus(active, "RapidFire", 25, 200)
    local loading = S.bonus(active, "Reload", 25, 200)
    cooldown = math.min(cooldown, math.max(S.option("RapidFireMinimum", 0.25, 0.1, 10), cooldown / (1 + rapid / 100)))
    reload = math.min(reload, math.max(S.option("ReloadMinimum", 0.25, 0, 10), reload / (1 + loading / 100)))
    if active.Autoloader then reload = 0 end
    local knockBonus = math.min((active.Velocity or 0) * S.option("VelocityKnockdownBonus", 5, 0, 100),
        math.max(0, S.option("VelocityKnockdownCap", 90, 0, 100) - knockdown))
    return {damage = damage * (1 + S.bonus(active, "Velocity", 20, 100) / 100),
        knockdown = math.min(100, knockdown + knockBonus),
        range = math.min(30, range + S.bonus(active, "Range", 2, 10)),
        ammo = math.floor(S.option("PotatoAmmoCapacity", 100, 1, 500) + capacity * S.option("CapacityAmmoBonus", 100, 0, 500)),
        modules = math.floor(S.option("PotatoModuleCapacity", 4, 0, 20) + capacity * S.option("CapacityModuleBonus", 4, 0, 20)),
        magazine = math.floor(S.option("PotatoMagazineCapacity", 1, 1, 500)),
        reload = reload * 1000, cooldown = cooldown * 1000, autoloader = active.Autoloader ~= nil}
end

return S
