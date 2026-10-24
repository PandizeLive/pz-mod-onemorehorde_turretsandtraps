if isServer() then return end
require("ISUI/ISInventoryPane")
local E = require("OMHTT/ControlExpansion")
local A = {applied = setmetatable({}, {__mode = "k"})}
A.texture = require("OMHTT/ControlExpansionTexture").texture

---@param item InventoryItem? Visible kit
---@return nil
function A.apply(item)
    local tier = E.tier(item)
    if tier == 0 then return end
    local texture, name = A.texture(tier)
    if not texture or A.applied[item] == name then return end
    item:setTexture(texture)
    item:setIcon(texture)
    A.applied[item] = name
end

local native = ISInventoryItem.renderItemIcon
---@param pane ISUIElement Surface
---@param item InventoryItem Visible item
---@param x number X
---@param y number Y
---@param alpha number? Opacity
---@param width number? Width
---@param height number? Height
---@return nil
function ISInventoryItem.renderItemIcon(pane, item, x, y, alpha, width, height)
    A.apply(item)
    native(pane, item, x, y, alpha, width, height)
end
return A
