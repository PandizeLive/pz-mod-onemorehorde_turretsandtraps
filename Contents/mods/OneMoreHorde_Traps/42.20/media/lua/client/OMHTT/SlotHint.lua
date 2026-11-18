if isServer() then return end
local Hint = {}
local kits = { ["Base.OMHTTModuleExpansionImprovised"] = 1, ["Base.OMHTTModuleExpansionSmall"] = 2, ["Base.OMHTTModuleExpansionMedium"] = 3, ["Base.OMHTTModuleExpansionLarge"] = 4 }

---@param slot ISPanel Empty-slot presentation
---@param fullType string? Representative accepted item, nil clears the hint
---@return nil
function Hint.set(slot, fullType)
    if kits[fullType] then
        slot.hintType = fullType
        slot.hintTexture = require("OMHTT/ControlExpansionTexture").texture(kits[fullType])
        return
    end
    if slot.hintType == fullType then return end
    slot.hintType, slot.hintTexture = fullType, nil
    if not fullType then return end
    local script = getScriptManager():getItem(fullType)
    if not script then return end
    local texture = script:getNormalTexture()
    local icons = script:getIconsForTexture()
    if icons and not icons:isEmpty() then
        texture = icons:get(0)
    end
    slot.hintTexture = texture
end

---@param slot ISPanel Slot with a cached normal icon
---@param x number Left
---@param y number Top
---@param size number Maximum icon size
---@return nil
function Hint.draw(slot, x, y, size)
    if not slot.hintTexture then return end
    size = math.min(size, slot.width - x - 2, slot.height - y - 2)
    if size <= 0 then return end
    -- A quiet grey backing keeps a black silhouette visible on the dark slot.
    slot:drawRect(x, y, size, size, 1, .28, .28, .28)
    slot:drawTextureScaledAspect(slot.hintTexture, x, y, size, size, .85, 0, 0, 0)
end

return Hint
