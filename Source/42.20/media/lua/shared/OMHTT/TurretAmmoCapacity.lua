local C = {}
C.rows = {
    Potato = {100, 250, 500, 750, 1000},
    Ballista = {40, 100, 175, 250, 350},
    Lobber = {20, 75, 150, 250, 350},
    Scrapshot = {20, 200, 400, 650, 900},
    Firearm = {250, 1000, 2500, 3750, 5000},
    Shotgun = {250, 400, 600, 800, 1000},
}
C.kits = {"CapacityImprovised", "CapacitySmall", "Capacity", "CapacityLarge"}
C.options = {"CapacityImprovisedAmmoBonus", "CapacitySmallAmmoBonus", "CapacityAmmoBonus", "CapacityLargeAmmoBonus"}
C.old = {100, 200, 400, 650}
C.multipliers = {2.5, 5, 7.5, 10}
C.multiplierOptions = {"AmmoMakeshiftMultiplier", "AmmoSmallMultiplier", "AmmoMediumMultiplier", "AmmoLargeMultiplier"}
C.bases = {Potato = 75, Ballista = 30, Lobber = 35, Scrapshot = 90, Firearm = 400, Shotgun = 80}

---@return boolean legacy Preserve an existing world's saved storage rules
function C.legacy()
    local settings = SandboxVars.OMHTurretsTraps
    if not settings or settings.AmmoUseMultipliers == true then return false end
    if type(settings.PotatoAmmoCapacity) == "number" and settings.PotatoAmmoCapacity >= 0 then return true end
    if type(settings.FirearmAmmoCapacity) == "number" and settings.FirearmAmmoCapacity >= 0 then return true end
    for i = 1, #C.options do
        local value = settings[C.options[i]]
        if type(value) == "number" and value >= 0 then return true end
    end
    return false
end

---@param tier number Expansion tier
---@return number multiplier Total capacity multiplier
function C.multiplier(tier)
    local settings = SandboxVars.OMHTurretsTraps
    local value = settings and settings[C.multiplierOptions[tier]]
    if type(value) ~= "number" or value ~= value then return C.multipliers[tier] end
    return math.max(1, math.min(100, value))
end

---@param tier number Expansion tier
---@param slots number Total active module slots
---@return string description Actual active storage policy
function C.description(tier, slots)
    if C.legacy() then return getText("UI_OMHTT_TurretKitLegacy", slots) end
    local value = string.gsub(string.format("%.2f", C.multiplier(tier)), "%.?0+$", "")
    return getText("UI_OMHTT_TurretKitCapacity", slots, value)
end

---@param kind string Head family
---@param active table Installed working modules
---@param base number Configured baseline
---@return number allowance
---@nodiscard
function C.resolve(kind, active, base)
    local row = C.rows[kind] or C.rows.Potato
    if not C.legacy() then
        local settings = SandboxVars.OMHTurretsTraps
        local value = settings and settings["AmmoBase" .. kind]
        local capacity = C.bases[kind] or base
        if type(value) == "number" and value == value then
            capacity = math.max(1, math.min(10000, value))
        end
        local multiplier = 1
        for i = 1, #C.kits do
            if active[C.kits[i]] then
                multiplier = math.max(multiplier, C.multiplier(i))
            end
        end
        return math.floor(capacity * multiplier)
    end
    local settings = SandboxVars.OMHTurretsTraps
    local key = kind == "Potato" and "PotatoAmmoCapacity" or "FirearmAmmoCapacity"
    if (kind == "Potato" or kind == "Firearm" or kind == "Shotgun") and (not settings or not settings[key] or settings[key] < 0) then
        base = row[1]
    end
    local result = base
    for i = 1, #C.kits do
        if active[C.kits[i]] then
            local multiplier = 1
            local value = settings and settings[C.options[i]]
            if type(value) == "number" and value == value and value >= 0 then
                multiplier = math.max(0, math.min(2000, value)) / C.old[i]
            end
            result = math.max(result, base + math.floor((row[i + 1] - row[1]) * multiplier))
        end
    end
    return result
end

return C
