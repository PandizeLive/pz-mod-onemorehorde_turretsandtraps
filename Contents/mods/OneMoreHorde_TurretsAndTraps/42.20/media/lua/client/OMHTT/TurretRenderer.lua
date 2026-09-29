if isClient() or isServer() then return end
local T = require("OMHTT/Turret")
local D = require("OMHTT/Diagnostics")
local R = {entries = {}, mode = nil, lastCheck = 0, headHeight = 0.4 - 16 / 192, headScale = 0.512}

---@param object IsoObject Managed base
---@param head InventoryItem? Actual installed head
---@return nil
function R.changed(object, head)
    if not T.state(object) then R.entries[object] = nil; return end
    if head then head:setWorldScale(R.headScale) end
    R.entries[object] = {head = head}
end

---@param square IsoGridSquare Loaded square
---@return nil
function R.loaded(square)
    local objects = square:getObjects()
    for i = 0, objects:size() - 1 do
        local object = objects:get(i)
        if T.state(object) and object:getContainer() then
            R.changed(object, T.contents(object:getContainer()).head)
        end
    end
end

---@param playerIndex number Native render viewport
---@return nil
function R.render(playerIndex)
    if not T.hybrid() then return end
    local player = getSpecificPlayer(playerIndex)
    if not player then return end
    for object, entry in pairs(R.entries) do
        local square, state = object:getSquare(), T.state(object)
        if object:getObjectIndex() < 0 or not square or not state
            or getCell():getGridSquare(square:getX(), square:getY(), square:getZ()) ~= square then
            R.entries[object] = nil
        elseif entry.head and square:getZ() == math.floor(player:getZ()) and square:isCanSee(playerIndex) then
            local dx, dy = square:getX() - player:getX(), square:getY() - player:getY()
            if dx * dx + dy * dy <= 80 * 80 then
                local heading = state.aimDegrees or (state.facing or 0) * 22.5
                local yaw = (360 - heading) % 360
                Render3DItem(entry.head, square, square:getX() + 0.5, square:getY() + 0.5, square:getZ() + R.headHeight, yaw)
            end
        end
    end
end

---@return nil
function R.tick()
    local now = getTimestampMs()
    if now - R.lastCheck < 1000 then return end
    R.lastCheck = now
    for object in pairs(R.entries) do
        local square = object:getSquare()
        if not square or object:getObjectIndex() < 0 or not T.state(object)
            or getCell():getGridSquare(square:getX(), square:getY(), square:getZ()) ~= square then
            R.entries[object] = nil
        end
    end
    local mode = T.hybrid()
    if mode == R.mode then return end
    R.mode = mode
    local W = require("OMHTT/TurretWorld")
    for object in pairs(R.entries) do
        if object:getObjectIndex() >= 0 and object:getSquare() then W.refresh(object) end
    end
    D.emit("turret-render-mode", {hybrid = mode, height = R.headHeight, scale = R.headScale, yawConvention = "negative-heading", pass = "opaque", looseHead = false})
end

Events.OnOMHTTTurretChanged.Add(R.changed)
Events.LoadGridsquare.Add(R.loaded)
Events.RenderOpaqueObjectsInWorld.Add(R.render)
Events.OnTick.Add(R.tick)
return R
