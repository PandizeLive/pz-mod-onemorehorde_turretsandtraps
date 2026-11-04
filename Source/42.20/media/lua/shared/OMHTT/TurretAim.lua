local Budget = require("OMHTT/TurretScheduler")
local Actors = require("OMHTT/DefenseActors")
local Clock = require("OMHTT/TurretClock")
local T = require("OMHTT/Turret")
local M = require("OMHTT/TurretModules")
local CombatPolicy = require("OMHTT/ControlCombat")
local Aim = {entries = {}, order = {}, queued = {}, cursor = 1}

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
    local x, y = Actors.position(target)
    return (math.atan2(-(y - square:getY() - 0.5), x - square:getX() - 0.5) * 180 / math.pi + 360) % 360
end

---@param object IsoObject Turret
---@param target IsoZombie Target
---@param player IsoPlayer? Manual operator
---@return boolean aligned
function Aim.request(object, target, player)
    if not CombatPolicy.eligible(object, target) then return false end
    local state = T.state(object)
    local desired = Aim.angle(object, target)
    local current = state.aimDegrees or (state.facing or 0) * 22.5
    if math.abs((desired - current + 540) % 360 - 180) <= 1 then
        Aim.entries[object] = nil
        return true
    end
    local now = Clock.now()
    local entry = Aim.entries[object]
    if not entry or entry.target ~= target or entry.player ~= player then
        if not Aim.queued[object] then
            Aim.order[#Aim.order + 1] = object
            Aim.queued[object] = true
        end
        entry = {target = target, player = player, last = now, checkAt = 0}
        Aim.entries[object] = entry
    end
    local contents = require("OMHTT/TurretWorld").contents(object)
    entry.speed = T.turnSpeed(contents.head, contents.active)
    entry.expires = now + 2000 + 360000 / entry.speed
    return false
end

---@param object IsoObject Powered turret
---@param contents table Current inventory summary
---@return nil
function Aim.face(object, contents)
    if Aim.entries[object] then return end
    local state = T.state(object)
    if not state or not state.facingPending then return end
    if not Aim.queued[object] then
        Aim.order[#Aim.order + 1] = object
        Aim.queued[object] = true
    end
    Aim.entries[object] = {direction = true, last = Clock.now(), speed = T.turnSpeed(contents.head, contents.active)}
end

---@param object IsoObject Turret
---@param entry table Bounded direction turn
---@param now number Active time
---@return nil
function Aim.turnFacing(object, entry, now)
    local W = require("OMHTT/TurretWorld")
    local state = T.state(object)
    if not state or not state.facingPending or not T.isOn(state) or not W.valid(object) then
        Aim.entries[object] = nil
        return
    end
    local contents = W.contents(object)
    if not contents.head or contents.head:getCondition() <= 0 or not W.power(object, contents) then
        Aim.entries[object] = nil
        return
    end
    entry.speed = T.turnSpeed(contents.head, contents.active)
    local elapsed = math.min(2000, math.max(0, now - entry.last)) / 1000
    entry.last = now
    local desired = M.heading(state)
    state.aimDegrees = Aim.move(state.aimDegrees or (state.facing or 0) * 22.5, desired, elapsed * entry.speed)
    if math.abs((desired - state.aimDegrees + 540) % 360 - 180) <= 1 then
        state.aimDegrees, state.facingPending = desired, nil
        state.facing = require("OMHTT/Foundation").normalizeFacing(math.floor(desired / 22.5 + .5))
        Aim.entries[object] = nil
        W.refresh(object)
        require("OMHTT/TurretAuthority").publish(object)
    end
end

---@return nil
function Aim.tick()
    if isClient() then return end
    local W = require("OMHTT/TurretWorld")
    local Combat = require("OMHTT/PrototypeCombat")
    local now = Clock.now()
    local deadline = Budget.limit(1)
    for i = 1, math.min(8, #Aim.order) do
        if getTimestampMs() >= deadline then return end
        if Aim.cursor > #Aim.order then Aim.cursor = 1 end
        local object = Aim.order[Aim.cursor]
        local entry = Aim.entries[object]
        if not entry then
            table.remove(Aim.order, Aim.cursor)
            Aim.queued[object] = nil
        elseif entry.direction then
            Aim.cursor = Aim.cursor + 1
            Aim.turnFacing(object, entry, now)
        else
            Aim.cursor = Aim.cursor + 1
            local state = T.state(object)
            local valid = state and T.isOn(state) and W.valid(object) and now <= entry.expires and CombatPolicy.eligible(object, entry.target)
            if valid and now >= entry.checkAt then
                local contents = W.contents(object)
                local stats = T.cycleConfig(contents)
                entry.speed = T.turnSpeed(contents.head, contents.active)
                valid = contents.head and contents.head:getCondition() > 0 and W.power(object, contents, stats)
                    and M.inside(object:getSquare(), entry.target, M.profile(state, contents, entry.player == nil, stats))
                    and Combat.clearLane(object:getSquare(), Actors.square(entry.target), stats.range)
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
                local elapsed = math.min(2000, math.max(0, now - entry.last)) / 1000
                entry.last = now
                state.aimDegrees = Aim.move(state.aimDegrees or (state.facing or 0) * 22.5, desired, elapsed * entry.speed)
                if math.abs((desired - state.aimDegrees + 540) % 360 - 180) <= 1 and entry.player then
                    Aim.entries[object] = nil
                    local result = W.fire(entry.player, object, entry.target)
                    require("OMHTT/TurretSearch").results[object] = {status = result, at = now}
                    if isServer() then
                        sendServerCommand(entry.player, "OMHTT_TurretControl", "Result", {id = state.id, status = result})
                    end
                end
            end
        end
    end
end

Budget.register("Aim.tick", Aim.tick)
return Aim
