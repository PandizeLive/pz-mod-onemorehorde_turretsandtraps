local A = {}

---@param name string Native combat key
---@return number value
---@nodiscard
local function setting(name)
    return getCombatConfig():get(CombatConfigKey[name])
end

---@param distance number Tiles
---@param prone boolean Target posture
---@return number modifier
---@nodiscard
function A.sightless(distance, prone)
    local pointBlank = setting("POINT_BLANK_DISTANCE")
    if distance > pointBlank then
        return (pointBlank - distance) * (setting("SIGHTLESS_TO_HIT_BASE_DISTANCE")
            + (distance - pointBlank) * setting("POINT_BLANK_DROP_OFF_TO_HIT_PENALTY"))
    end
    local modifier = (pointBlank - distance) / pointBlank * setting("POINT_BLANK_TO_HIT_MAXIMUM_BONUS")
    if prone then modifier = modifier * setting("SIGHTLESS_TO_HIT_PRONE_MODIFIER") end
    return modifier
end

---@param distance number Tiles
---@param minimum number Native minimum sight range
---@param maximum number Native maximum sight range
---@return number modifier
---@nodiscard
function A.sights(distance, minimum, maximum)
    local delta = 0
    if distance < minimum then
        if distance <= setting("POINT_BLANK_DISTANCE") then return 0 end
        delta = minimum - distance
    elseif distance > maximum then
        delta = distance - maximum
    else
        if maximum <= minimum then return setting("OPTIMAL_RANGE_TO_HIT_MAXIMUM_BONUS") end
        local center = minimum + (maximum - minimum) * 0.5
        local width = 2 * (maximum - minimum) / 7
        return setting("OPTIMAL_RANGE_TO_HIT_MAXIMUM_BONUS") * math.exp(-((distance - center) / width) ^ 2)
    end
    return -delta * (setting("OPTIMAL_RANGE_DROP_OFF_TO_HIT_PENALTY")
        + delta * setting("OPTIMAL_RANGE_DROP_OFF_TO_HIT_PENALTY_INCREMENT"))
end

---@param gun HandWeapon Mounted gun
---@param stats table Base turret tuning
---@param distance number Tiles
---@param prone boolean Target posture
---@return number chance Percent
---@nodiscard
function A.chance(gun, stats, distance, prone)
    if stats.accuracy <= 0 then return 0 end
    local far = stats.farAccuracy
    local fraction = math.min(1, math.max(0, distance / stats.range))
    local close = math.max(far, math.max(stats.accuracy, math.min(95, stats.accuracy + A.sightless(0, prone))))
    local balanced = close + (far - close) * fraction
    return math.min(100, balanced)
end

return A
