local H = {cache = {}}
local configurable = {damage = {0, 2500}, range = {1, 64}, cooldown = {.1, 60}, reload = {.1, 60}, shove = {0, 100}}
H.definitions = {
    ["Base.OMHTTTurretLobber"] = {key = "Lobber", damage = 150, range = 18, minimumRange = 6, cooldown = 5.5, reload = 4, magazine = 3, ammoCapacity = 20, weight = 8},
    ["Base.OMHTTTurretScrapshot"] = {key = "Scrapshot", ammo = "Base.ScrapMetal", damage = 320, range = 8, cone = 90, cooldown = 2, reload = 3, magazine = 10, weight = 6},
    ["Base.OMHTTTurretBallista"] = {key = "Ballista", ammo = "Base.SpearCrafted", damage = 240, range = 24, cooldown = 6, reload = 6, magazine = 5, cone = 45, ammoCapacity = 40, weight = 6},
    ["Base.OMHTTTurretRotaryBat"] = {key = "RotaryBat", rotary = true, damage = 20, range = 2, shove = 40, weight = 5},
    ["Base.OMHTTTurretRotaryBlades"] = {key = "RotaryBlades", rotary = true, damage = 40, range = 2, shove = 10, weight = 6},
}
H.excluded = {Filter = true, Splitter = true, Piercing = true, Conservation = true, Magazine = true, Reload = true,
    Autoloader = true, Impact = true, Fragment = true, Range = true, Accuracy = true, Void = true}

---@param item InventoryItem? Head
---@return table? definition
---@nodiscard
function H.get(item)
    if not item then return nil end
    local base = H.definitions[item:getFullType()]
    if not base then return nil end
    local cached = H.cache[base.key]
    if not cached then
        cached = {}
        for key, value in pairs(base) do cached[key] = value end
        H.cache[base.key] = cached
    end
    local settings = SandboxVars.OMHTurretsTraps or {}
    for key, bounds in pairs(configurable) do
        if base[key] and (key ~= "range" or not base.rotary) then
            local suffix = string.upper(string.sub(key, 1, 1)) .. string.sub(key, 2)
            local value = settings[base.key .. suffix]
            cached[key] = type(value) == "number" and math.max(bounds[1], math.min(bounds[2], value)) or base[key]
        end
    end
    return cached
end

---@param item InventoryItem? Head
---@param name string Module identity
---@return boolean supported
---@nodiscard
function H.supports(item, name)
    local definition = H.get(item)
    if definition and definition.key == "Lobber" and name == "Piercing" then return false end
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
    local stroke = math.floor(travel / 90)
    local offset = travel % 90
    if stroke % 2 == 1 then
        offset = 90 - offset
    end
    return offset - 45, stroke
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
        elseif math.abs(angle) <= 45 then
            local first, last = math.floor(before / 90), math.floor(after / 90)
            for stroke = first, last do
                local phase = angle + 45
                if stroke % 2 == 1 then
                    phase = 90 - phase
                end
                local crossing = stroke * 90 + phase
                if crossing > before and crossing <= after then return arm + 1, stroke end
            end
        end
    end
    return nil
end

return H
