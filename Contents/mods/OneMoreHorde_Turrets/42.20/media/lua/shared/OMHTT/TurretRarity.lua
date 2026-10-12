local L = require("OMHTT/LootDefinitions")
local R = {cache = {}}
R.surcharges = {.1, .15, .25, .4, .6, .8, 1}
R.stops = {{130,174,255}, {115,204,255}, {89,230,102}, {255,250,77}, {255,148,51}, {255,46,46}, {66,13,130}}

---@param settings table Loaded sandbox values
---@return nil
function R.refresh(settings)
    R.initialized = true
    local weights, low, high = {}, math.huge, 0
    for name, base in pairs(L.WEIGHTS) do
        local multiplier = settings["LootRate" .. name]
        if type(multiplier) ~= "number" then multiplier = L.DEFAULTS.items[name] end
        local weight = base * math.max(0, math.min(20, multiplier))
        if settings.ModuleLootRate == 0 then weight = 0 end
        weights[name] = weight
        if weight > 0 then low, high = math.min(low, weight), math.max(high, weight) end
    end
    R.cache = {}
    for name, weight in pairs(weights) do
        local color, band = {150,150,150}, 1
        if weight > 0 and high > low then
            band = math.floor(math.log(high / weight) / math.log(high / low) * 6 + .5) + 1
            color = R.stops[math.max(1, math.min(7, band))]
        end
        if weight <= 0 then
            local baseLow, baseHigh = math.huge, 0
            for _, value in pairs(L.WEIGHTS) do baseLow, baseHigh = math.min(baseLow, value), math.max(baseHigh, value) end
            band = math.floor(math.log(baseHigh / L.WEIGHTS[name]) / math.log(baseHigh / baseLow) * 6 + .5) + 1
            color = R.stops[band]
        elseif high == low then color = R.stops[1] end
        R.cache[name] = {band = band, surcharge = R.surcharges[band], weight = weight, r = color[1] / 255, g = color[2] / 255, b = color[3] / 255,
            tr = .55 + color[1] / 255 * .45, tg = .55 + color[2] / 255 * .45, tb = .55 + color[3] / 255 * .45}
    end
end

---@param name string Module key
---@return table color Cached palette and effective weight
function R.get(name)
    if not R.initialized then
        R.refresh(SandboxVars.OMHTurretsTraps or {})
        R.initialized = true
    end
    return R.cache[name] or R.neutral
end

R.neutral = {band = 1, surcharge = .1, r = 130/255, g = 174/255, b = 1, tr = .78, tg = .86, tb = 1}
Events.OnGameStart.Add(function() R.refresh(SandboxVars.OMHTurretsTraps or {}) end)
return R
