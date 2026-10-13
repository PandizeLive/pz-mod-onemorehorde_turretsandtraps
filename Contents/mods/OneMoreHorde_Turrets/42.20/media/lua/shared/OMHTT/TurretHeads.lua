local H = {}
H.definitions = {
    ["Base.OMHTTTurretBallista"] = {key = "Ballista", ammo = "Base.SpearCrafted", damage = 240, range = 18, cooldown = 6, weight = 6},
    ["Base.OMHTTTurretRotaryBat"] = {key = "RotaryBat", rotary = true, damage = 20, range = 1.25, shove = 40, weight = 5},
    ["Base.OMHTTTurretRotaryBlades"] = {key = "RotaryBlades", rotary = true, damage = 40, range = 1.25, shove = 10, weight = 6},
}
H.excluded = {Filter = true, Splitter = true, Piercing = true, Conservation = true, Magazine = true, Reload = true,
    Autoloader = true, Impact = true, Fragment = true, Tack = true, Martyrdom = true, Synergy = true, Range = true, Accuracy = true}

---@param item InventoryItem? Head
---@return table? definition
---@nodiscard
function H.get(item)
    if not item then return nil end
    return H.definitions[item:getFullType()]
end

---@param item InventoryItem? Head
---@param name string Module identity
---@return boolean supported
---@nodiscard
function H.supports(item, name)
    local definition = H.get(item)
    return not definition or not definition.rotary or not H.excluded[name]
end

---@param stats table Ballista stats
---@param distance number Tiles
---@return number chance Percent
---@nodiscard
function H.accuracy(stats, distance)
    local fraction = math.max(0, math.min(1, distance / stats.range))
    return stats.accuracy + (stats.farAccuracy - stats.accuracy) * fraction
end

---@param travel number Total angular travel
---@param omni boolean Full rotation
---@return number angle Relative degrees
---@return number stroke Pass identity
---@nodiscard
function H.motion(travel, omni)
    if omni then return travel % 360, math.floor(travel / 360) end
    local stroke = math.floor(travel / 45)
    local offset = travel % 45
    if stroke % 2 == 1 then
        offset = 45 - offset
    end
    return offset - 22.5, stroke
end

---@param bearing number Heading relative to placement axis
---@param before number Previous travel
---@param after number Current travel, at most one short observed sweep
---@param omni boolean Full rotation
---@return number? arm Physical arm identity
---@return number? pass Distinct crossing identity
---@nodiscard
function H.crossing(bearing, before, after, omni)
    if after <= before then return nil end
    for arm = 0, 1 do
        local angle = (bearing - arm * 180 + 540) % 360 - 180
        if omni then
            local phase = (angle + 360) % 360
            local pass = math.floor((after - phase) / 360)
            local crossing = pass * 360 + phase
            if crossing > before and crossing <= after then return arm + 1, pass end
        elseif math.abs(angle) <= 22.5 then
            local first, last = math.floor(before / 45), math.floor(after / 45)
            for stroke = first, last do
                local phase = angle + 22.5
                if stroke % 2 == 1 then
                    phase = 45 - phase
                end
                local crossing = stroke * 45 + phase
                if crossing > before and crossing <= after then return arm + 1, math.floor(crossing / 45) end
            end
        end
    end
    return nil
end

return H
