local Diagnostics = require("OMHTT/Diagnostics")
local Sprites = {}
Sprites.SHEET = "omhtt_barrier_01_"

---@param record table Persistent barrier
---@return string entity
---@nodiscard
function Sprites.entity(record)
    if record.tier == "reinforced" or record.constructionEntity == "OMHTTDeployReinforcedBarrier" then return "OMHTTDeployReinforcedBarrier" end
    if record.constructionEntity == "OMHTTDeploySpikeBarrier" then return record.constructionEntity end
    return "OMHTTSpikeBarrier"
end

---@param record table Persistent barrier
---@param square IsoGridSquare Part tile
---@return string name
---@nodiscard
function Sprites.name(record, square)
    local index = record.facing / 2
    if square:getX() ~= record.x or square:getY() ~= record.y then
        index = index + 1
    end
    if Sprites.entity(record) == "OMHTTDeployReinforcedBarrier" then
        index = index + 20
    elseif Sprites.entity(record) == "OMHTTDeploySpikeBarrier" then
        index = index + 8
    end
    return Sprites.SHEET .. index
end

---@param object IsoThumpable Exact loaded part
---@param record table Persistent barrier
---@param reason string? Reconciliation origin
---@return boolean changed
function Sprites.ensure(object, record, reason)
    local desired = Sprites.name(record, object:getSquare())
    local oldName = object:getSpriteName()
    local changed = oldName ~= desired
    if changed then
        object:setSpriteFromName(desired)
    end
    local config = object:getSpriteConfig()
    local valid = config and config:isValid() and config:getTileInfo():getSpriteName() == desired
    if not valid then
        local info = SpriteConfigManager.GetObjectInfo(Sprites.entity(record))
        if not info then error("[OMHTT] Missing barrier entity: " .. Sprites.entity(record)) end
        if config then
            GameEntityFactory.RemoveComponentType(object, ComponentType.SpriteConfig)
        end
        local replacement = ComponentType.SpriteConfig:CreateComponentFromScript(info:getScript())
        GameEntityFactory.AddComponent(object, replacement)
        config = object:getSpriteConfig()
        if not config or not config:isValid() then error("[OMHTT] Failed to restore barrier part " .. record.id) end
        changed = true
    end
    if changed or reason == "load" then
        local square = object:getSquare()
        Diagnostics.emit("barrier-restoration", {id = record.id, origin = reason, x = square:getX(), y = square:getY(),
            z = square:getZ(), previousSprite = tostring(oldName), sprite = desired, spriteId = object:getSprite():getID(),
            entity = config:getObjectInfo():getName(), nativeConfigValid = config:isValid(), changed = changed,
            facing = record.facing, condition = record.condition, owner = record.testOwner}, nil, nil, "traps")
    end
    return changed
end

return Sprites
