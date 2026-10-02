local T = require("OMHTT/Turret")
local M = require("OMHTT/TurretModules")
local Aim = {entries = {}}

---@param current number Actual degrees
---@param desired number Desired degrees
---@param step number Maximum travel
---@return number angle
---@nodiscard
function Aim.move(current, desired, step)
    local delta = (desired - current + 540) % 360 - 180
    return (current + math.max(-step, math.min(step, delta)) + 360) % 360
end

---@param object IsoObject Turret
---@param target IsoZombie Target
---@return number degrees
---@nodiscard
function Aim.angle(object, target)
    local square = object:getSquare()
    return (math.atan2(-(target:getY() - square:getY() - 0.5), target:getX() - square:getX() - 0.5) * 180 / math.pi + 360) % 360
end

---@param object IsoObject Turret
---@param target IsoZombie Target
---@param player IsoPlayer? Manual operator
---@return boolean aligned
function Aim.request(object, target, player)
    local state = T.state(object)
    local desired = Aim.angle(object, target)
    local current = state.aimDegrees or (state.facing or 0) * 22.5
    if math.abs((desired - current + 540) % 360 - 180) <= 1 then
        Aim.entries[object] = nil
        return true
    end
    local now = getTimestampMs()
    local entry = Aim.entries[object]
    if not entry or entry.target ~= target or entry.player ~= player then
        entry = {target = target, player = player, last = now, checkAt = 0}
        Aim.entries[object] = entry
    end
    entry.speed = T.turnSpeed(T.contents(object:getContainer()).head)
    entry.expires = now + 2000 + 360000 / entry.speed
    return false
end

---@return nil
function Aim.tick()
    if isClient() or isServer() then return end
    local W = require("OMHTT/TurretWorld")
    local Combat = require("OMHTT/PrototypeCombat")
    local now = getTimestampMs()
    for object, entry in pairs(Aim.entries) do
        local state = T.state(object)
        local valid = state and T.isOn(state) and W.valid(object) and now <= entry.expires
        if valid and now >= entry.checkAt then
            local contents = T.contents(object:getContainer())
            entry.speed = T.turnSpeed(contents.head)
            valid = contents.head and contents.head:getCondition() > 0 and W.power(object, contents)
                and M.inside(object:getSquare(), entry.target, M.profile(state, contents))
                and Combat.clearLane(object:getSquare(), entry.target:getSquare(), T.cycleConfig(contents).range)
            if entry.player then
                valid = valid and W.near(entry.player, object)
            else
                valid = valid and M.detects(state, contents)
            end
            entry.checkAt = now + 100
        end
        if not valid then
            Aim.entries[object] = nil
            if entry.player then
                require("OMHTT/TurretSearch").results[object] = {status = "Unavailable", at = now}
            end
        else
            local desired = Aim.angle(object, entry.target)
            local elapsed = math.min(100, math.max(0, now - entry.last)) / 1000
            entry.last = now
            state.aimDegrees = Aim.move(state.aimDegrees or (state.facing or 0) * 22.5, desired, elapsed * entry.speed)
            if math.abs((desired - state.aimDegrees + 540) % 360 - 180) <= 1 and entry.player then
                Aim.entries[object] = nil
                local result = W.fire(entry.player, object, entry.target)
                require("OMHTT/TurretSearch").results[object] = {status = result, at = now}
            end
        end
    end
end

Events.OnTick.Add(Aim.tick)
return Aim
