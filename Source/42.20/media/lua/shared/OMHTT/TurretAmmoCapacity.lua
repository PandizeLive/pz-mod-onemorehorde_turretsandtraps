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

---@param kind string Head family
---@param active table Installed working modules
---@param base number Configured baseline
---@return number allowance
---@nodiscard
function C.resolve(kind, active, base)
    local row = C.rows[kind] or C.rows.Potato
    local result = base
    local settings = SandboxVars.OMHTurretsTraps
    for i = 1, #C.kits do
        if active[C.kits[i]] then
            local multiplier = 1
            local value = settings and settings[C.options[i]]
            if type(value) == "number" and value == value then
                multiplier = math.max(0, math.min(2000, value)) / C.old[i]
            end
            result = math.max(result, base + math.floor((row[i + 1] - row[1]) * multiplier))
        end
    end
    return result
end

return C
