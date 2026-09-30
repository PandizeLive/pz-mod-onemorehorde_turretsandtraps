if isClient() or isServer() then return end
local T = require("OMHTT/Turret")
local D = require("OMHTT/Diagnostics")
local M = require("OMHTT/TurretModules")
local R = {entries = {}, mode = nil, lastCheck = 0, headHeight = 0.4 - 16 / 192, headScale = 0.512}

---@param object IsoObject Managed base
---@param head InventoryItem? Actual installed head
---@return nil
function R.changed(object, head)
    if not T.state(object) then R.entries[object] = nil; return end
    if head then head:setWorldScale(R.headScale) end
    local entry = R.entries[object] or {}
    entry.head, entry.profile = head, M.profile(T.state(object), T.contents(object:getContainer()))
    R.entries[object] = entry
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

---@param object IsoObject Managed base
---@return number heading
---@nodiscard
function R.heading(object)
    local state, entry = T.state(object), R.entries[object]
    if entry and entry.visualHeading then return entry.visualHeading end
    return state.aimDegrees or (state.facing or 0) * 22.5
end

---@param now number Current tick timestamp
---@return nil
function R.animate(now)
    local A = require("OMHTT/TurretAutomation")
    local speed = M.option("IdleSweepSpeed", 30, 0, 180)
    for object, entry in pairs(R.entries) do
        local state, automatic = T.state(object), A.entries[object]
        if state then
            local elapsed = math.min(100, math.max(0, now - (entry.lastFrame or now))) / 1000
            entry.lastFrame = now
            if automatic and automatic.status == "no-target" and entry.head and speed > 0 then
                local profile = entry.profile
                local cone = M.option("ForwardCone", 90, 10, 360)
                if profile.omni then
                    cone = 360
                end
                local offset = ((R.heading(object) - profile.heading + 180) % 360) - 180
                offset = math.max(-cone / 2, math.min(cone / 2, offset))
                local phase = entry.sweepPhase or (offset + cone / 2) / cone
                phase = (phase + elapsed * speed / cone) % 2
                entry.sweepPhase = phase
                local position = phase
                if phase > 1 then
                    position = 2 - phase
                end
                entry.visualHeading = (profile.heading - cone / 2 + position * cone + 360) % 360
            else
                entry.sweepPhase = nil
                if automatic and automatic.target then
                    entry.visualHeading = state.aimDegrees
                elseif state.aimDegrees ~= entry.lastAim then
                    entry.visualHeading = state.aimDegrees
                end
            end
            entry.lastAim = state.aimDegrees
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
                local heading = R.heading(object)
                local yaw = (360 - heading) % 360
                Render3DItem(entry.head, square, square:getX() + 0.5, square:getY() + 0.5, square:getZ() + R.headHeight, yaw)
            end
        end
    end
end

---@return nil
function R.tick()
    local now = getTimestampMs()
    R.animate(now)
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
