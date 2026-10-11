local F = require("OMHTT/Foundation")
local D = require("OMHTT/Diagnostics")
local H = {ITEM = "Base.OMHTTTurretProbe", SPRITE = "omhtt_turret_01_20"}
OMHTT_HybridProbe = H

---@param square IsoGridSquare? Probe square
---@return IsoObject? base
---@return IsoWorldInventoryObject? head
---@nodiscard
function H.find(square)
    if not square then return nil, nil end
    local base, head
    local objects = square:getObjects()
    for i = 0, objects:size() - 1 do
        local object = objects:get(i)
        if object:getModData().OMHTTHybridProbe then
            base = object
        end
    end
    if not base then return nil, nil end
    local items = square:getWorldObjects()
    for i = 0, items:size() - 1 do
        local world = items:get(i)
        local item = world:getItem()
        if item and item:getModData().OMHTTHybridProbe == base:getModData().OMHTTHybridProbe then
            head = world
        end
    end
    return base, head
end

---@param player IsoPlayer Operator
---@param square IsoGridSquare? Target
---@return boolean allowed
---@nodiscard
function H.allowed(player, square)
    if isClient() or isServer() or not F.canUse(player) or not square then return false end
    return math.floor(player:getZ()) == square:getZ()
        and math.abs(player:getX() - square:getX()) <= 4 and math.abs(player:getY() - square:getY()) <= 4
end

---@param player IsoPlayer Operator
---@param square IsoGridSquare Target
---@return IsoObject? base
---@return IsoWorldInventoryObject? head
function H.create(player, square)
    if not H.allowed(player, square) or not square:TreatAsSolidFloor() or square:isSolid() or square:isSolidTrans() then return nil, nil end
    if H.find(square) then return nil, nil end
    local item = instanceItem(H.ITEM)
    if not item then return nil, nil end
    local id = "probe-" .. tostring(item:getID())
    local base = IsoObject.new(square, H.SPRITE, "OMHTT Hybrid Probe")
    base:getModData().OMHTTHybridProbe = id
    item:getModData().OMHTTHybridProbe = id
    item:setWorldXRotation(0)
    item:setWorldYRotation(0)
    item:setWorldZRotation(0)
    item:setWorldScale(1)
    square:AddTileObject(base)
    square:AddWorldInventoryItem(item, 0.5, 0.5, 0.3)
    base:invalidateRenderChunkLevel(FBORenderChunk.DIRTY_REDRAW)
    D.emit("hybrid-probe-created", {id = id, item = item:getFullType(), model = item:getWorldStaticItem(),
        x = square:getX(), y = square:getY(), z = square:getZ(), height = 0.3, scale = 1})
    return base, item:getWorldItem()
end

---@param head IsoWorldInventoryObject Head instance
---@param angle number Degrees
---@return nil
function H.rotate(head, angle)
    head:getItem():setWorldZRotation(angle % 360)
    head:invalidateRenderChunkLevel(FBORenderChunk.DIRTY_REDRAW)
end

---@param player IsoPlayer Operator
---@param square IsoGridSquare Target
---@return nil
function H.remove(player, square)
    if not H.allowed(player, square) then return end
    local base, head = H.find(square)
    if head then
        square:transmitRemoveItemFromSquare(head)
    end
    if base then
        D.emit("hybrid-probe-removed", {id = base:getModData().OMHTTHybridProbe})
        square:transmitRemoveItemFromSquare(base)
    end
end

return H
