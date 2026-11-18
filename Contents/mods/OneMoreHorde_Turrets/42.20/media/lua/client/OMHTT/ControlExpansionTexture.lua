if isServer() then return end
local R = require("OMHTT/ControlRarity")
local A = {textures = {}}
local components = {"CapacityImprovised", "CapacitySmall", "Capacity", "CapacityLarge"}

---@param tier integer Expansion tier from one to four
---@return Texture? texture
---@return string? name
function A.texture(tier)
    if not components[tier] then return nil end
    local color = R.get(components[tier])
    local name = "expansion_" .. string.lower(R.names[color.band])
    if not A.textures[name] then
        A.textures[name] = getTexture("media/textures/OMHTT/Modules/" .. name .. ".png")
    end
    return A.textures[name], name
end

return A
