if isClient() then return end
-- Requests are transient and server-owned; unloading never resumes a shot.
local C = {pending = {}, blocked = {}, due = setmetatable({}, {__mode = "k"})}

---@param object IsoObject Receiver
---@return nil
function C.cancel(object)
    C.pending[object] = nil
end

---@param object IsoObject Receiver
---@return nil
function C.manualOff(object)
    C.cancel(object)
    C.blocked[object] = true
end

---@param object IsoObject Receiver
---@return boolean managed
function C.managed(object)
    local linked = require("OMHTT/ControlWorld").input(object, getTimestampMs())
    return linked
end

---@param object IsoObject Receiver
---@return boolean allowed
function C.canFire(object)
    if not C.managed(object) then return true end
    local cycle = C.pending[object]
    return cycle ~= nil and not cycle.finishing
end

---@param object IsoObject Receiver
---@return boolean started
function C.request(object)
    local T = require("OMHTT/Turret")
    local Clock = require("OMHTT/TurretClock")
    if C.pending[object] or C.blocked[object] then return false end
    local world = require("OMHTT/TurretWorld")
    if not world.valid(object) then return false end
    local contents = world.contents(object)
    if contents.heads ~= 1 or not contents.active.Firing or contents.head:getCondition() <= 0 then return false end
    local stats = T.cycleConfig(contents)
    if not world.power(object, contents, stats) or (not stats.rotary and contents.ammo == 0) then return false end
    local turn = 360000 / math.max(1, T.turnSpeed(contents.head, contents.active))
    local wake = 0
    if contents.active.MotionDetection then
        wake = require("OMHTT/TurretModules").option("TurretWakeSeconds", 1, 0, 10) * 1000
    end
    C.pending[object] = {head = contents.head, expires = Clock.now() + turn + wake + require("OMHTT/TurretModules").option("TurretAlertDelay", .25, 0, 5) * 1000 + (stats.reload or 0) + (stats.cooldown or 0) + 5000, rotary = stats.rotary}
    if not T.isOn(T.state(object)) then
        world.applyPower(object, true)
    end
    return true
end

---@param object IsoObject Receiver
---@return nil
function C.fired(object)
    local cycle = C.pending[object]
    if not cycle then return end
    if cycle.rotary then
        cycle.finishing = true
        return
    end
    C.pending[object] = nil
    C.due[object] = getTimestampMs() + 100
    local _, on = require("OMHTT/ControlWorld").input(object, getTimestampMs())
    if not on then
        require("OMHTT/TurretWorld").applyPower(object, false)
    end
end

---@param object IsoObject Receiver
---@param on boolean Held input
---@param valid boolean At least one loaded, healthy input remains
---@return nil
function C.step(object, on, valid)
    local T = require("OMHTT/Turret")
    local Clock = require("OMHTT/TurretClock")
    local world = require("OMHTT/TurretWorld")
    local state = T.state(object)
    if not state then C.cancel(object); return end
    if not valid or object:getHealth() <= 0 then
        C.cancel(object)
        on, valid = false, false
    end
    if not on then
        C.blocked[object] = nil
    end
    if on and valid and getTimestampMs() >= (C.due[object] or 0) then
        C.request(object)
    end
    local cycle = C.pending[object]
    if cycle then
        local contents = world.contents(object)
        local stats = T.cycleConfig(contents)
        if contents.head ~= cycle.head or not contents.active.Firing or cycle.head:getCondition() <= 0
            or not world.power(object, contents, stats) or Clock.now() >= cycle.expires then
            C.cancel(object)
        elseif cycle.finishing then
            if not state.rotaryMoving and (not state.rotaryManual or Clock.now() >= state.rotaryManual) then
                C.cancel(object)
            end
        elseif not state.facingPending then
            local auto = require("OMHTT/TurretAutomation").entries[object]
            if not contents.active.MotionDetection or (auto and (auto.target or (cycle.rotary and auto.hasTarget))) then
                local result = require("OMHTT/ControlWorld").fireSignal(object)
                if result == "Fired" or result == "Misfire" then
                    C.fired(object)
                elseif result ~= "Waking" and result ~= "Turning" and result ~= "Aiming" and result ~= "Reloading" and result ~= "Cooling" then
                    C.cancel(object)
                end
            elseif auto and auto.status == "no-target" then
                C.cancel(object)
            end
        end
    end
    if not C.pending[object] and not on and state and T.isOn(state) then
        world.applyPower(object, false)
    end
end

return C
