local L = require("OMHTT/ControlLootDefinitions")
local R = {cache = {}}
R.surcharges = {.15, .25, .5, .75, 1, 1.5, 2}
R.stops = {{130,174,255}, {115,204,255}, {89,230,102}, {255,250,77}, {255,148,51}, {255,46,46}, {66,13,130}}
R.names = {"Abundant", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic"}

---@param settings table Loaded sandbox values
---@return table|nil anchors Custom weights, or automatic mode
---@return string|nil error Invalid custom configuration
local function readAnchors(settings)
    local anchors, configured = {}, false
    for i = 1, #R.names do
        local value = settings["RarityWeight" .. R.names[i]] or 0
        anchors[i] = value
        if value ~= 0 then
            configured = true
        end
    end
    if not configured then return nil end
    for i = 1, #anchors do
        local value = anchors[i]
        if type(value) ~= "number" or value ~= value or value <= 0 or value > 1000000 then
            return nil, "All seven rarity weights must be positive and finite. Using automatic rarity."
        end
        if i > 1 and value >= anchors[i - 1] then
            return nil, "Rarity weights must decrease from Abundant to Mythic. Using automatic rarity."
        end
    end
    return anchors
end

---@param weight number Positive effective item weight
---@param low number Minimum positive weight
---@param high number Maximum positive weight
---@param boundaries table|nil Cached custom proportional boundaries
---@return integer band One-based rarity
local function classify(weight, low, high, boundaries)
    if boundaries then
        for i = 1, #boundaries do
            if weight > boundaries[i] then return i end
        end
        return 7
    end
    if high <= low then return 1 end
    return math.max(1, math.min(7, math.floor(math.log(high / weight) / math.log(high / low) * 6 + .5) + 1))
end

---@param settings table Loaded sandbox values
---@return nil
function R.refresh(settings)
    local normalized = {}
    for key, value in pairs(settings) do normalized[key:gsub("^Traps", "")] = value end
    for key, value in pairs(settings) do if not string.find(key, "^Traps") then normalized[key] = value end end
    settings = normalized
    R.initialized = true
    R.observed = {}
    for key, value in pairs(settings) do
        if string.sub(key, 1, 8) == "LootRate" or string.sub(key, 1, 12) == "RarityWeight" or key == "ModuleLootRate" then
            R.observed[key] = value
        end
    end
    local anchors, error = readAnchors(settings)
    if error and error ~= R.anchorError then
        print("[OMHTT] " .. error)
    end
    R.anchorError = error
    local boundaries
    if anchors then
        boundaries = {}
        for i = 1, #anchors - 1 do
            boundaries[i] = math.sqrt(anchors[i] * anchors[i + 1])
        end
    end
    local weights, low, high, baseLow, baseHigh = {}, math.huge, 0, math.huge, 0
    for name, base in pairs(L.CATALOG) do
        baseLow, baseHigh = math.min(baseLow, base), math.max(baseHigh, base)
        local multiplier = settings["LootRate" .. name]
        if type(multiplier) ~= "number" then
            multiplier = L.MANUALS[name] and -1 or L.DEFAULTS.items[name]
        end
        if L.MANUALS[name] and multiplier < 0 then
            multiplier = anchors and anchors[L.MANUALS[name]] or L.DEFAULTS.items[name]
        end
        local weight = base * math.max(0, math.min(1000000, multiplier))
        if settings.ModuleLootRate == 0 then
            weight = 0
        end
        weights[name] = weight
        if weight > 0 then
            low, high = math.min(low, weight), math.max(high, weight)
        end
    end
    R.cache = {}
    for name, weight in pairs(weights) do
        local band
        if weight <= 0 then
            -- Owned items remain usable when their loot is disabled.
            band = classify(L.CATALOG[name], baseLow, baseHigh, boundaries)
        else
            band = classify(weight, low, high, boundaries)
        end
        local color = R.stops[band]
        R.cache[name] = {band = band, surcharge = R.surcharges[band], weight = weight, r = color[1] / 255, g = color[2] / 255, b = color[3] / 255,
            tr = .55 + color[1] / 255 * .45, tg = .55 + color[2] / 255 * .45, tb = .55 + color[3] / 255 * .45}
    end
end

---@param name string Module key
---@return table color Cached palette and effective weight
function R.get(name)
    local now = getTimestampMs()
    if now >= (R.checkAt or 0) then
        R.checkAt = now + 1000
        local settings = SandboxVars.OMHTurretsTraps or {}
        local changed = not R.initialized
        for key, value in pairs(R.observed or {}) do
            if (settings[key] or settings["Traps" .. key]) ~= value then changed = true end
        end
        for key, value in pairs(settings) do
            if (string.sub(key, 1, 8) == "LootRate" or string.sub(key, 1, 12) == "RarityWeight" or key == "ModuleLootRate")
                and (not R.observed or R.observed[key] ~= value) then changed = true end
        end
        if changed then R.refresh(settings) end
    end
    if not R.initialized then
        R.refresh(SandboxVars.OMHTurretsTraps or {})
    end
    return R.cache[name] or R.neutral
end

R.neutral = {band = 1, surcharge = R.surcharges[1], r = 130/255, g = 174/255, b = 1, tr = .78, tg = .86, tb = 1}
Events.OnGameStart.Add(function() R.refresh(SandboxVars.OMHTurretsTraps or {}) end)
return R
