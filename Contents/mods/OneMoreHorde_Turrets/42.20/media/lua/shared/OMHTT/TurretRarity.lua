local L = require("OMHTT/LootDefinitions")
local R = {cache = {}}
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
        local color = {150,150,150}
        if weight > 0 and high > low then
            local band = math.floor(math.log(high / weight) / math.log(high / low) * 6 + .5) + 1
            color = R.stops[math.max(1, math.min(7, band))]
        end
        R.cache[name] = {weight = weight, r = color[1] / 255, g = color[2] / 255, b = color[3] / 255,
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

R.neutral = {r = .4, g = .4, b = .4, tr = .75, tg = .75, tb = .75}
return R
