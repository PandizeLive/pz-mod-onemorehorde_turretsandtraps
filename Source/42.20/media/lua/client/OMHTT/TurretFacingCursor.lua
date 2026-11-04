if isServer() then return end
local A = require("OMHTT/ControlAccess")
local U = require("OMHTT/ControlClient")
local Range = require("OMHTT/TurretRange")
local Cursor = {}

---@param square IsoGridSquare? Selected world tile
---@return boolean valid
function Cursor:isValid(square)
    local host, target = A.state(self.host), A.state(self.target)
    return not self.owner.closed and host ~= nil and target ~= nil
        and host.id == self.hostId and target.id == self.targetId
        and A.write(self.character, host) and A.write(self.character, target)
        and ((self.host == self.target and A.near(self.character, self.target))
            or require("OMHTT/ControlRemote").valid(self.character, self.host, self.target))
        and square ~= nil and square:getZ() == self.target:getZ()
        and (square:getX() ~= self.target:getX() or square:getY() ~= self.target:getY())
end

---@param x number Tile X
---@param y number Tile Y
---@return number degrees
---@nodiscard
function Cursor:angle(x, y)
    return (math.atan2(self.target:getY() - y, x - self.target:getX()) * 180 / math.pi + 360) % 360
end

---@param x number Tile X
---@param y number Tile Y
---@param z number Floor
---@param square IsoGridSquare? Cursor tile
---@return nil
function Cursor:render(x, y, z, square)
    if not self:isValid(square) then
        Range.preview[self.player] = nil
        return
    end
    local degrees = self:angle(x, y)
    local preview = Range.preview[self.player]
    if not preview then
        preview = {object = self.target}
        Range.preview[self.player] = preview
    end
    preview.heading = degrees
    self:getFloorCursorSprite():RenderGhostTileColor(x, y, z, .7, .85, 1, .7)
end

---@param x number Tile X
---@param y number Tile Y
---@param z number Floor
---@param north boolean Native cursor orientation
---@param sprite string? Native cursor sprite
---@return nil
function Cursor:create(x, y, z, north, sprite)
    local square = getCell():getGridSquare(x, y, z)
    if self:isValid(square) then
        U.command(self.character, self.host, "SetFacing", self:angle(x, y), self.target)
    end
    getCell():setDrag(nil, self.player)
end

---@return nil
function Cursor:deactivate()
    Range.preview[self.player] = nil
    Range.focus(self.player, "facing", self.target, false)
    if self.owner.cursor == self then
        self.owner.cursor = nil
        if not self.owner.closed then
            self.owner:setVisible(true)
            self.owner:bringToTop()
        end
    end
end

---@param panel ISPanel Controller menu
---@return ISBuildingObject? cursor
function Cursor.start(panel)
    local targetObject = panel.deviceId and panel.object or panel.selected
    local hostObject = panel.deviceId and (panel.controller or panel.object) or panel.object
    if panel.deviceId and A.near(panel.player, targetObject) then
        hostObject = targetObject
    end
    local target, host = A.state(targetObject), A.state(hostObject)
    if not target or target.kind ~= "Turret" or not host
        or not A.write(panel.player, host) or not A.write(panel.player, target)
        or not ((hostObject == targetObject and A.near(panel.player, targetObject))
            or require("OMHTT/ControlRemote").valid(panel.player, hostObject, targetObject)) then return nil end
    require("BuildingObjects/ISBuildingObject")
    local cursor = ISBuildingObject:derive("OMHTTTurretFacingSelection")
    for key, value in pairs(Cursor) do
        cursor[key] = value
    end
    cursor:init()
    cursor.owner, cursor.host, cursor.target = panel, hostObject, targetObject
    cursor.hostId, cursor.targetId = host.id, target.id
    cursor.character, cursor.player = panel.player, panel.player:getPlayerNum()
    cursor.noNeedHammer, cursor.skipBuildAction = true, true
    panel.nameEntry:commit()
    panel.cursor = cursor
    Range.focus(cursor.player, "facing", cursor.target, true)
    panel:setVisible(false)
    getCell():setDrag(cursor, cursor.player)
    return cursor
end

return Cursor
