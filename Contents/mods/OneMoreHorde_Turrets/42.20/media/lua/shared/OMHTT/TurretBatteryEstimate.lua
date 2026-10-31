local E = {}

---@param stats table Effective shot/cycle values
---@param gun HandWeapon? Mounted firearm
---@param count number Remaining firing actions
---@return number milliseconds Estimated continuous-use time, never consumption
function E.duration(stats, gun, count, currentLoaded, currentDebt)
    if count <= 0 then return 0 end
    if stats.ammoFree then return (count - 1) * stats.cooldown end
    local capacity = math.max(1, stats.magazine)
    local divisor = stats.conservation or 1
    local cost = 1 + (stats.splitter or 0)
    local first = E.magazineUses(currentLoaded or capacity, cost, divisor, currentDebt or 0)
    local shots = E.magazineUses(capacity, cost, divisor, 0)
    local reload = stats.reload
    local rack = 0
    if stats.firearm and gun then
        if not gun:getMagazineType() then reload = reload * capacity end
        if gun:haveChamber() then rack = stats.rack end
    end
    local cadence = stats.cooldown
    local cycles = count > first and 1 + math.floor((count - first - 1) / shots) or 0
    return (count - 1) * cadence + cycles * math.max(0, reload + rack - cadence)
end

---@param loaded number Ready physical rounds
---@param cost number Undiscounted maximum charge
---@param divisor number Conservation uses per round
---@param debt number Existing fractional charge
---@return number shots Actions until empty
function E.magazineUses(loaded, cost, divisor, debt)
    local shots = 0
    if loaded >= cost then
        local run = math.ceil(((loaded - cost + 1) - debt) * divisor / cost - .0000001)
        local total = debt + run * cost / divisor
        local spend = math.floor(total + .0000001)
        loaded, debt, shots = loaded - spend, total - spend, run
    end
    while loaded > 0 do
        local total = debt + math.min(loaded, cost) / divisor
        local spend = math.floor(total + .0000001)
        loaded, debt, shots = loaded - spend, math.max(0, total - spend), shots + 1
    end
    return shots
end

return E
