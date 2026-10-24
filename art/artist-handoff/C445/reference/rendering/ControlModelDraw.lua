if isServer() then return end
local D = {}

---@return nil
function D.restore()
    local entry = D.pending
    if not entry then return end
    entry.item:setWorldXRotation(entry.x)
    entry.item:setWorldYRotation(entry.y)
    entry.item:setWorldZRotation(entry.z)
    entry.atlas:setValue(entry.default)
    entry.atlas:setDefaultToCurrentValue()
    entry.atlas:setValue(entry.enabled)
    D.pending = nil
end

---@param item InventoryItem Model
---@param square IsoGridSquare Lighting and visibility tile
---@param x number World X
---@param y number World Y
---@param z number World Z
---@param rx number Native item X rotation
---@param ry number Native item Y rotation
---@param rz number Native item Z rotation
---@return nil
function D.draw(item, square, x, y, z, rx, ry, rz)
    D.restore()
    local entry = D.buffer or {}
    D.buffer, D.pending = entry, entry
    local atlas = D.atlas or getDebugOptions():getOptionByName("WorldItemAtlas.Enable")
    D.atlas = atlas
    entry.item, entry.x, entry.y, entry.z = item, item:getWorldXRotation(), item:getWorldYRotation(), item:getWorldZRotation()
    entry.atlas, entry.default, entry.enabled = atlas, atlas:getDefaultValue(), atlas:getValueAsString() == "true"
    item:setWorldXRotation(rx)
    item:setWorldYRotation(ry)
    item:setWorldZRotation(rz)
    atlas:setValue(false)
    atlas:setDefaultToCurrentValue()
    Render3DItem(item, square, x, y, z, -1)
    D.restore()
end
Events.OnTick.Add(D.restore)
return D
