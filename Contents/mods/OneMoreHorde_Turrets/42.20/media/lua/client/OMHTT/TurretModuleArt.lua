if isServer() then return end
require("ISUI/ISInventoryPane")
local T = require("OMHTT/Turret")
local R = require("OMHTT/TurretRarity")
local A = {textures = {}, applied = setmetatable({}, {__mode = "k"})}
local performance = {Regulator = true, Conservation = true, Magazine = true, RapidFire = true,
    Velocity = true, Range = true, Suppression = true, Critical = true, Accuracy = true, Reload = true, Autoloader = true}
local utility = {Grid = true, Siphon = true, Lure = true, Void = true}
local effects = {Piercing = true, InitialBlow = true, Execute = true, Impact = true,
    Splitter = true, Fragment = true, Synergy = true, Martyrdom = true, Tack = true}

local automation = {FiringEnhanced = true, MotionDetectionEnhanced = true, Firing = true, Filter = true, MotionDetection = true, Detection360 = true, MotionDetectionImprovised = true, FiringImprovised = true}

---@param item InventoryItem? Existing or newly received item
---@return nil
function A.apply(item)
    if not item then return end
    local component = T.component(item:getFullType())
    local category = performance[component] and "performance" or utility[component] and "utility"
        or effects[component] and "effects" or automation[component] and "automation"
    if not category then return end
    local name = category .. "_" .. string.lower(R.names[R.get(component).band])
    if A.applied[item] == name then return end
    local texture = A.textures[name]
    if not texture then
        texture = getTexture("media/textures/OMHTT/Modules/" .. name .. ".png")
        if not texture then return end
        A.textures[name] = texture
    end
    item:setTexture(texture)
    item:setIcon(texture)
    A.applied[item] = name
end

-- Hook the native icon entry point: no extra container scan, including icon mode.
local nativeIcon = ISInventoryItem.renderItemIcon
---@param pane ISUIElement Native drawing surface
---@param item InventoryItem Visible item
---@param x number Horizontal position
---@param y number Vertical position
---@param alpha number? Opacity
---@param width number? Width
---@param height number? Height
---@return nil
function ISInventoryItem.renderItemIcon(pane, item, x, y, alpha, width, height)
    A.apply(item)
    nativeIcon(pane, item, x, y, alpha, width, height)
end

return A
